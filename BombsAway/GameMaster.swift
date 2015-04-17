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
    func onPlayerAppeared(player : FBPlayer)
    func onPlayerDisappeared(player : FBPlayer)
    //actions
    //func addPlayer(name : String)
    func setBombState(state : BombState)
}

class GameMaster {
    //Singleton
    static let sharedInstance = GameMaster()
    
    //wired up by app delegate
    var me : FBPlayer?
    var players = [String:FBPlayer]()
    
    var clients = [String:IGameClient]()
    var root = Firebase(url: "https://shining-torch-5343.firebaseio.com/BombsAway/")
    
    init() {
        let ref = root.childByAppendingPath("players")
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            self.fbOnPlayerAdded(snapshot)
        })
        ref.observeEventType(.ChildRemoved, withBlock: { snapshot in
            self.fbOnPlayerRemoved(snapshot)
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
    
    
    //MARK: - registration
    //we need a key because you cant reference compare protocols ( or search arrays for them )
    func registerClient(key : String, client : IGameClient) {
        clients[key] = client
    }
    
    func removeClient(key : String) {
        clients.removeValueForKey(key)
    }
    
   
    static func getPlayers(completion: (players : [FBPlayer]) -> Void) {
        var ref = sharedInstance.root.childByAppendingPath("players")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            println(snapshot)
            println("Firebase players query returned")
            //note we use as! here because it is guaranteed to have something if the event got fired
            completion(players: [])
        })
    }
    
    //MARK:  calls from View Controller
    func addPlayer(name : String) {
        let ref = root.childByAppendingPath("players")
        let child = ref.childByAutoId()
        child.onDisconnectRemoveValue()
        var values = ["id":child.key, "name":name]
        child.setValue(values)
    }
    
}
