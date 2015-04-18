//
//  AdamViewController.swift
//  BombsAway
//
//  Created by Adam Rothberg on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import UIKit

class AdamViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imgBomb: UIImageView!
    @IBOutlet weak var imgExplosion: UIImageView!
    @IBAction func buttonUp(sender: AnyObject) {
        moveBomb()
    }
    var i = 0
    var movingBomb = false
    let fusePlayer = AudioPlayer(filename: "fuse")
    let boomPlayer = AudioPlayer(filename: "boom")
    let pingPlayer = AudioPlayer(filename: "ping")
    var bombStartingPosition : CGPoint!
    
    func moveBomb()
    {
        if (movingBomb) {
            return
        }
        
        movingBomb = true
        imgExplosion.hidden = true
        imgBomb.hidden = false
        let random = Misc.GetRandom(0, endingInclusive: 3)
        switch(random)
        {
        case 0:
            bombStartingPosition = CGPoint(x: self.view.center.x, y: -imgBomb.frame.height / 2)
        case 1:
            bombStartingPosition = CGPoint(x: self.view.frame.width + imgBomb.frame.width / 2, y: self.view.center.y)
        case 2:
            bombStartingPosition = CGPoint(x: self.view.center.x, y: imgBomb.frame.height / 2 + self.view.frame.height)
        case 3:
            bombStartingPosition = CGPoint(x: -imgBomb.frame.width / 2, y: self.view.center.y)
        default:
            var e = NSException(name:"name", reason:"invalid case", userInfo:nil)
            e.raise()
        }
        imgBomb.center = bombStartingPosition

        UIView.animateWithDuration(1,
            animations: { () -> Void in
            // do actual move
            self.fusePlayer.play()
            self.imgBomb.center = self.view.center
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
                            self.imgExplosion.fadeOut(duration: 0.5)
                        })
                    self.movingBomb = false
                    self.resendBomb()
                }
        })
    }
    
    func resendBomb()
    {
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("moveBomb"), userInfo: nil, repeats: false)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    @IBAction func tapBomb(sender: UIGestureRecognizer) {
        if (movingBomb)
        {
            let p = sender.locationInView(self.view)
            let hit = imgBomb.layer.presentationLayer().hitTest(p) != nil
            println("hit\(i++)? \(hit)")
            if (hit)
            {
                let layer = imgBomb.layer.presentationLayer() as! CALayer
                let frame = layer.frame
                imgBomb.layer.removeAllAnimations()
                imgBomb.frame = frame
            
                UIView.animateWithDuration(0.1,
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
                            self.movingBomb = false
                            self.resendBomb()
                        }
                })
            }
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBomb.hidden = true
        imgExplosion.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

