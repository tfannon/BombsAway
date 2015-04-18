//
//  FirebaseDTOs.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//


class FBPlayer : Printable {
    var id : String
    var name : String
    
    init(snapshot : FDataSnapshot) {
        self.id = snapshot.value["id"] as! String
        self.name = snapshot.value["name"] as! String
    }
    
    init(dict: NSDictionary) {
        self.id = dict.objectForKey("id") as! String
        self.name = dict.objectForKey("name") as! String
    }
    
    
    var description : String {
        return "\(self.id):\(self.name)"
    }
}


class FBBomb {
    var ttl : Int
    var senderId : String
    var senderName : String
    var receiverId : String
    var receiverName : String
    
    init(ttl : Int, senderId : String, senderName : String, receiverId : String, receiverName : String) {
        self.ttl = ttl
        self.senderId = senderId
        self.senderName = senderName
        self.receiverId = receiverId
        self.receiverName = receiverName
    }
    
    init(snapshot : FDataSnapshot) {
        self.ttl = (snapshot.value["ttl"] as! String).toInt()!
        self.senderId = snapshot.value["senderId"] as! String
        self.senderName = snapshot.value["senderName"] as! String
        self.receiverId = snapshot.value["receiverId"] as! String
        self.receiverName = snapshot.value["receiverName"] as! String
    }
    
    init(dict: NSDictionary) {
        self.ttl = (dict.objectForKey("ttl") as! String).toInt()!
        self.senderId = dict.objectForKey("senderId") as! String
        self.senderName = dict.objectForKey("senderName") as! String
        self.receiverId = dict.objectForKey("receiverId") as! String
        self.receiverName = dict.objectForKey("receiverName") as! String
    }
    
}