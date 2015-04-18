//
//  GameMaster.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//
enum BombState {
    case Detonted
    case Defused
}

protocol IGameClient {
    //events
    func onBombAppeared(bomb : FBBomb)
    func onBombed(bomb: FBBomb)
    func onBombDisappeared(bomb : FBBomb)
    func onPlayerAppeared(player : FBPlayer)
    func onPlayerDisappeared(player : FBPlayer)
    func onPlayerChanged(player : FBPlayer)
    func onLastPlayerDisappeared()
}

class GameMaster {
    //Singleton
    static let sharedInstance = GameMaster()
    
    private var players = [String:FBPlayer]()
    private var bomb : FBBomb!
    private var bombKey : String!
    private var me : FBPlayer!
    
    private var clientToPlayer = [String:String]()
    
    private var clients = [String:IGameClient]()
    private var root = Firebase(url: "https://shining-torch-5343.firebaseio.com/BombsAway/")
    private var playersRef : Firebase
    private var bombsRef : Firebase

    
    init() {
        playersRef = root.childByAppendingPath("players")
        bombsRef = root.childByAppendingPath("bombs")
        
        playersRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.fbOnPlayerAdded(snapshot)
        })
        playersRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
            self.fbOnPlayerRemoved(snapshot)
        })
        playersRef.observeEventType(.ChildChanged, withBlock: { snapshot in
            self.fbOnPlayerChanged(snapshot)
        })

        bombsRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.fbOnBombAdded(snapshot)
        })
        bombsRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
            self.fbOnBombRemoved(snapshot)
        })
    }
    
    //MARK: -- event callbacks from firebase
    func fbOnPlayerAdded(snapshot : FDataSnapshot) {
        var p = FBPlayer(snapshot: snapshot)
        players[p.id] = p
        for x in clients {
            x.1.onPlayerAppeared(p)
        }
    }
    
    func fbOnPlayerRemoved(snapshot : FDataSnapshot) {
        var p = FBPlayer(snapshot: snapshot)
        players.removeValueForKey(p.id)
        for x in clients {
            x.1.onPlayerDisappeared(p)
            if (players.count == 0)
            {
                x.1.onLastPlayerDisappeared()
            }
        }
    }
    
    func fbOnPlayerChanged(snapshot : FDataSnapshot) {
        var p = FBPlayer(snapshot: snapshot)
        players[p.id] = p
        for x in clients.values.array {
            x.onPlayerChanged(p)
        }
    }
    
    func fbOnBombAdded(snapshot : FDataSnapshot) {
        self.bomb = FBBomb(snapshot: snapshot)
        self.bombKey = snapshot.key
        
        for (k,v) in clients {
            //what player is this client managing
            let playerId = clientToPlayer[k]
            //if this player is the receiver of the bomb
            if bomb.receiverId == playerId {
                v.onBombed(bomb)
            }
            else {
                v.onBombAppeared(bomb)
            }
        }
    }
    
    func fbOnBombRemoved(snapshot : FDataSnapshot) {
    }
    
//    func fbOnBombAdded(snapshot : FDataSnapshot) {
//        var b = FBBomb(snapshot: snapshot)
//        bombs[snapshot.key] = b
//        for (k,v) in clients {
//            //what player is this client managing
//            let playerId = clientToPlayer[k]
//            //if this player is the receiver of the bomb
//            if b.receiverId == playerId {
//                v.onBombed(b)
//            }
//            else {
//                v.onBombAppeared(b)
//            }
//       }
//    }
    

    //MARK: - registration
    func registerClient(key : String, client : IGameClient) {
        clients[key] = client
    }
    
    func removeClient(key : String) {
        clients.removeValueForKey(key)
    }
    
    //MARK:  calls from View Controller
    func addPlayer(clientKey : String, name : String) {
        //first get the running list of players
        getPlayers() { (result) in
            //add this player to firebase
            let child = self.playersRef.childByAutoId()
            child.onDisconnectRemoveValue()
            var dict = ["id":child.key, "name":name, "score":0]
            child.setValue(dict)
            
            let p = FBPlayer(dict: dict)
            self.me = p
            self.clientToPlayer[clientKey] = p.id
            if result.count == 1 {
                self.plantBomb(result[0])
            }
        }
    }
    
    func detonate(clientKey : String) {
        let pRef = playersRef.childByAppendingPath(me.id)
        me.score--
        pRef.updateChildValues(["score":me.score])
        choosePlayerAndBomb()
    }
    
    func defuse(clientKey : String) {
        let pRef = playersRef.childByAppendingPath(me.id)
        me.score++
        pRef.updateChildValues(["score":me.score])
        choosePlayerAndBomb()
    }
    
    private func choosePlayerAndBomb() {
        //this will remove entire bombs node.. change to remove singular
        bombsRef.removeValue()
        let otherPlayers = players.values.array.filter { $0.id != self.me?.id }
        if (otherPlayers.count > 0)
        {
            let idx = Misc.GetRandom(0, endingInclusive: otherPlayers.count-1)
            plantBomb(otherPlayers[idx])
        }
    }
    
    //MARK:  internal helper methods
    private func getPlayers(completion: (players : [FBPlayer]) -> Void) {
        var ref = root.childByAppendingPath("players")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            println("Firebase players query returned")
            println(snapshot)
            var players = [FBPlayer]()
            if let tmp = snapshot.value as? [String:NSDictionary] {
                for (k,v) in tmp {
                    players.append(FBPlayer(dict: v))
                }
            }
            completion(players: players)
        })
    }
    
    private func plantBomb(player : FBPlayer) {
        let bomb = bombsRef.childByAutoId()
        var dict = ["ttl":"10", "senderId":self.me!.id, "senderName": self.me!.name, "receiverId": player.id, "receiverName": player.name]
        bomb.setValue(dict)
   }
}
