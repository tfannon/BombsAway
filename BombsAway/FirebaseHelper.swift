//
//  FirebaseHelper.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation

class FirebaseHelper {
    //Singleton
    static let sharedInstance = FirebaseHelper()
    var root = Firebase(url: "https://shining-torch-5343.firebaseio.com/BombsAway/")
    
    static func getPlayers(completion: (players : [FBPlayer]) -> Void) {
        var ref = sharedInstance.root.childByAppendingPath("players")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            println(snapshot)
            println("Firebase players query returned")
            //note we use as! here because it is guaranteed to have something if the event got fired
            completion(players: [])
        })
    }
    
    static func addPlayer(name : String,  completion: (player : FBPlayer) -> Void) {
        let ref = sharedInstance.root.childByAppendingPath("players")
        let child = ref.childByAutoId()
        child.onDisconnectRemoveValue()
//        child.onDisconnectRemoveValueWithCompletionBlock() { (error, firebase) in
//            println("received callback for addPlayer disconnect")
//        }
        var values = ["name":name, "id":child.key]
        child.setValue(values)
        completion(player: FBPlayer(userId: child.key, userName:name))
    }
}