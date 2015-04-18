//
//  ViewController.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IGameClient {

    var gameMaster = GameMaster.sharedInstance

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var events: UITextView!
    
    @IBAction func addPlayer(sender: AnyObject) {
        gameMaster.addPlayer(name.text)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gameMaster.registerClient("Test", client: self)
    }
    
    //MARK: - UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        events.text = ""
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //var x = UIGestureRecognizer()
        let aTouch = event.allTouches()!.first as! UITouch
        let touchLocation = aTouch.locationInView(aTouch.view)
        self.myImage.center = touchLocation
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let aTouch = event.allTouches()!.first as! UITouch
        let touchLocation = aTouch.locationInView(aTouch.view)
        if aTouch.view.isEqual(self.view) {
            self.myImage.center = touchLocation
        }
    }
    
    //MARK:  IGameClient
    func onBombAppeared(bomb : FBBomb) {
        events.text = events.text + "\(bomb) appeared\r\n"
    }
    
    func onBombDisappeared(bomb : FBBomb) {
        events.text = events.text + "\(bomb) disappeared\r\n"
    }
    
    func onPlayerAppeared(player : FBPlayer) {
        events.text = events.text + "\(player) joined\r\n"
    }

    func onPlayerDisappeared(player : FBPlayer) {
        events.text = events.text + "\(player) left\r\n"
    }
}

