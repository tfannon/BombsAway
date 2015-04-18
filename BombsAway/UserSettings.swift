//
//  UserSettings.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/18/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation

class UserSettings {

    static let sharedInstance = UserSettings()
    
    func getUserName() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("Name") as? String
    }
    
    func setUserName(name : String) {
        NSUserDefaults.standardUserDefaults().setObject(name, forKey: "Name")
    }

}