//
//  NSObjectExtensions.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/18/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

public extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}

public extension String {
    var length: Int { return count(self) }  // Swift 1.2
    
    func sub(length : Int) -> String {
        let index = advance(self.startIndex, length)
        return self.substringToIndex(index)
    }
}
