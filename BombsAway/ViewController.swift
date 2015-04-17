//
//  ViewController.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var root = Firebase(url: "https://shining-torch-5343.firebaseio.com/BombsAway/")

    @IBOutlet weak var myImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseHelper.addPlayer("Tommy") { (result) in
            println("Player added: ]\(result)")
        }
        root.observeSingleEventOfType(.Value, withBlock: { snapshot in
            println(snapshot.value)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
}

