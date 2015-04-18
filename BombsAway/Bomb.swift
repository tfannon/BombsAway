//
//  Bomb.swift
//  BombsAway
//
//  Created by Adam Rothberg on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import UIKit

protocol IBombListener {
    //events
    func onExploded(bomb : Bomb)
    func onDiffusedAndSent(bomb : Bomb)
}

class Bomb
{
    let uiView : UIView!
    let imgBomb : UIImageView!
    let imgExplosion : UIImageView!
    let listener : IBombListener!
 
    let fusePlayer = AudioPlayer(filename: "fuse")
    let boomPlayer = AudioPlayer(filename: "boom")
    let pingPlayer = AudioPlayer(filename: "ping")
    
    var bombStartingPosition : CGPoint!
    var calculating = false;
    
    func incoming()
    {
        imgExplosion.hidden = true
        imgBomb.hidden = false
        let random = Misc.GetRandom(0, endingInclusive: 3)
        switch(random)
        {
        case 0:
            bombStartingPosition = CGPoint(x: uiView.center.x, y: -imgBomb.frame.height / 2)
        case 1:
            bombStartingPosition = CGPoint(x: uiView.frame.width + imgBomb.frame.width / 2, y: uiView.center.y)
        case 2:
            bombStartingPosition = CGPoint(x: uiView.center.x, y: imgBomb.frame.height / 2 + uiView.frame.height)
        case 3:
            bombStartingPosition = CGPoint(x: -imgBomb.frame.width / 2, y: uiView.center.y)
        default:
            var e = NSException(name:"name", reason:"invalid case", userInfo:nil)
            e.raise()
        }
        imgBomb.center = bombStartingPosition
        
        UIView.animateWithDuration(1,
            animations: { () -> Void in
                // do actual move
                self.fusePlayer.play()
                self.imgBomb.center = self.uiView.center
            },
            completion: { (complete) -> Void in
                if (complete)
                {
                    //when animation completes
                    self.imgBomb.hidden = true
                    self.imgExplosion.center = self.imgBomb.center
                    self.imgExplosion.hidden = false
                    self.imgExplosion.alpha = 0
                    self.fusePlayer.stop()
                    self.boomPlayer.play()
                    self.imgExplosion.fadeIn(duration: 0.2, completion: { (completed) -> Void in
                        self.imgExplosion.fadeOut(duration: 0.5, completion: { (completed) -> Void in
                            self.listener.onExploded(self)
                        })
                    })
                }
            }
        )
    }
    
    func tryDiffuseAndSend(point : CGPoint!)
    {
        if (!calculating)
        {
            calculating = true;
            let hit = imgBomb.layer.presentationLayer().hitTest(point) != nil
            if (hit)
            {
                let layer = imgBomb.layer.presentationLayer() as! CALayer
                let frame = layer.frame
                imgBomb.layer.removeAllAnimations()
                imgBomb.frame = frame
                
                UIView.animateWithDuration(0.3,
                    animations: { () -> Void in
                        // do actual move
                        self.pingPlayer.play()
                        self.imgBomb.center = self.bombStartingPosition
                    },
                    completion: { (complete) -> Void in
                        if (complete)
                        {
                            //when animation completes
                            self.pingPlayer.stop()
                            self.listener.onDiffusedAndSent(self)
                            self.calculating = false
                        }
                })
            }
            else
            {
                calculating = false
            }
        }
    }
    
    init(listener : IBombListener, uiView : UIView, imgBomb : UIImageView, imgExplosion : UIImageView)
    {
        self.listener = listener
        self.uiView = uiView
        self.imgBomb = imgBomb
        self.imgExplosion = imgExplosion
    }
    
}