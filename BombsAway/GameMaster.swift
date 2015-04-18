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
}

class GameMaster {
    //Singleton
    static let sharedInstance = GameMaster()
    
    private var players = [String:FBPlayer]()
    private var bombs = [String:FBBomb]()
    private var me : FBPlayer?
    
    private var clientToPlayer = [String:String]()
    
    private var clients = [String:IGameClient]()
    private var root = Firebase(url: "https://shining-torch-5343.firebaseio.com/BombsAway/")
    private var playerRef : Firebase
    private var bombRef : Firebase

    
    init() {
        playerRef = root.childByAppendingPath("players")
        bombRef = root.childByAppendingPath("bombs")
        
        playerRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.fbOnPlayerAdded(snapshot)
        })
        playerRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
            self.fbOnPlayerRemoved(snapshot)
        })

        bombRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.fbOnBombAdded(snapshot)
        })
        bombRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
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
        }
    }
    
    func fbOnBombAdded(snapshot : FDataSnapshot) {
        var b = FBBomb(snapshot: snapshot)
        bombs[snapshot.key] = b
        for (k,v) in clients {
            //what player is this client managing
            let playerId = clientToPlayer[k]
            //if this player is the receiver of the bomb
            if b.receiverId == playerId {
                v.onBombed(b)
            }
            else {
                v.onBombAppeared(b)
            }
       }
    }
    
    func fbOnBombRemoved(snapshot : FDataSnapshot) {
        var p = FBBomb(snapshot: snapshot)
        bombs.removeValueForKey(snapshot.key)
        for x in clients {
            x.1.onBombDisappeared(p)
            
        }
    }
    
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
            let child = self.playerRef.childByAutoId()
            child.onDisconnectRemoveValue()
            var dict = ["id":child.key, "name":name]
            child.setValue(dict)
            
            let p = FBPlayer(dict: dict)
            self.me = p
            self.clientToPlayer[clientKey] = p.id
            if result.count == 1 {
                self.plantBomb(result[0])
            }
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
    
    func plantBomb(player : FBPlayer) {
        let child = bombRef.childByAutoId()
        bombRef.onDisconnectRemoveValue()
        var dict = ["ttl":"10", "senderId":self.me!.id, "senderName": self.me!.name, "receiverId": player.id, "receiverName": player.name]
        child.setValue(dict)
        bombs[child.key] = FBBomb(dict: dict)
    }
}
