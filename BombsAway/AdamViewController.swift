//
//  AdamViewController.swift
//  BombsAway
//
//  Created by Adam Rothberg on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import UIKit

class AdamViewController: UIViewController, IBombListener, IGameClient, UITextFieldDelegate {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imgBomb: UIImageView!
    @IBOutlet weak var imgExplosion: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    
    var i = 0
    var bomb : Bomb?
    var gameMaster = GameMaster.sharedInstance

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gameMaster.registerClient(self.nameOfClass, client: self)
    }
    
    // MARK: text field
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: bomb events
    func onDiffusedAndSent(bomb: Bomb) {
        self.bomb = nil
        newIncomingBomb()
    }
    
    func onExploded(bomb: Bomb) {
        self.bomb = nil
        newIncomingBomb()
    }
    
    func newIncomingBomb()
    {
        if (bomb == nil)
        {
            bomb = Bomb(listener: self, uiView: self.view, imgBomb: imgBomb, imgExplosion: imgExplosion)
            bomb!.incoming()
        }
    }
    
    @IBAction func tapBomb(sender: UIGestureRecognizer) {
        if (bomb != nil)
        {
            let p = sender.locationInView(self.view)
            bomb!.tryDiffuseAndSend(p)
        }
    }
    
    // MARK: GameMaster
    @IBAction func buttonUp(sender: AnyObject) {
        UserSettings.sharedInstance.setUserName(txtName.text)
        gameMaster.addPlayer(self.nameOfClass, name: txtName.text)
        button.hidden = true
        txtName.hidden = true
    }
    
    func onBombed(bomb: FBBomb) {
        newIncomingBomb()
    }
    func onBombAppeared(bomb: FBBomb) {
        
    }
    func onBombDisappeared(bomb: FBBomb) {
        
    }
    func onPlayerAppeared(player: FBPlayer) {
        
    }
    func onPlayerDisappeared(player: FBPlayer) {
        
    }
    
    // MARK: Standard iOS Stuff
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.delegate = self; // ADD THIS LINE
        imgBomb.hidden = true
        imgExplosion.hidden = true
        txtName.text = UserSettings.sharedInstance.getUserName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

