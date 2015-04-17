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
    
    var description : String {
        return "\(self.id):\(self.name)"
    }
}


class FBBomb {
    var color : String?
    var ttl : Int?
    var sender : String?
}