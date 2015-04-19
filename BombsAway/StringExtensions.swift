//
//  StringExtensions.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/19/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

public extension String {
    var length: Int { return count(self) }  // Swift 1.2
    
    func sub(length : Int) -> String {
        let index = advance(self.startIndex, length)
        return self.substringToIndex(index)
    }
}
