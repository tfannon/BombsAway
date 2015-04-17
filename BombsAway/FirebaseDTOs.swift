//
//  FirebaseDTOs.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//


class FBPlayer {
    var userId : String
    var userName : String

    init (userId : String, userName : String) {
        self.userId = userId
        self.userName = userName
    }
}