//
//  AdamViewController.swift
//  BombsAway
//
//  Created by Adam Rothberg on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import UIKit

class AdamViewController: UIViewController, IBombListener {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imgBomb: UIImageView!
    @IBOutlet weak var imgExplosion: UIImageView!
    
    var i = 0
    var bomb : Bomb?
    
    func onDiffusedAndSent(bomb: Bomb) {
        newIncomingBomb()
    }
    
    func onExploded(bomb: Bomb) {
        newIncomingBomb()
    }
    
    func newIncomingBomb()
    {
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("newIncomingBombImpl"), userInfo: nil, repeats: false)
    }
    func newIncomingBombImpl()
    {
        bomb = Bomb(listener: self, uiView: self.view, imgBomb: imgBomb, imgExplosion: imgExplosion)
        bomb!.incoming()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    @IBAction func tapBomb(sender: UIGestureRecognizer) {
        if (bomb != nil)
        {
            let p = sender.locationInView(self.view)
            bomb!.tryDiffuseAndSend(p)
        }
    }
    
    @IBAction func buttonUp(sender: AnyObject) {
        newIncomingBomb()
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

