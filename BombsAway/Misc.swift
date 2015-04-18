//
//  Misc.swift
//  BombsAway
//
//  Created by Adam Rothberg on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation

class Misc
{
    class func GetRandom(startingInclusive : Int, endingInclusive : Int) -> Int
    {
        let diff = UInt32(endingInclusive - startingInclusive + 1)
        let rand = Int(arc4random_uniform(diff))
        let result = rand + startingInclusive
        return result
    }
}