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
    let gameMaster = GameMaster.sharedInstance
    var gameMasterClientKey : String!
    
    let SINGLE_PLAYER_MODE = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gameMasterClientKey = self.nameOfClass
        gameMaster.registerClient(gameMasterClientKey, client: self)
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
        if SINGLE_PLAYER_MODE
        {
            newIncomingBomb()
        }
        else
        {
            gameMaster.defuse(gameMasterClientKey);
        }
    }
    
    func onExploded(bomb: Bomb) {
        self.bomb = nil
        if (SINGLE_PLAYER_MODE)
        {
            newIncomingBomb()
        }
        else
        {
            gameMaster.detonate(gameMasterClientKey)
        }
    }
    
    func newIncomingBomb()
    {
        if (bomb == nil)
        {
            // random time interval between .5 - 1 second
            let ttl = Double(Misc.GetRandom(5, endingInclusive: 10)) / 10.0
            bomb = Bomb(
                listener: self,
                ttl: 1,
                uiView: self.view,
                imgBomb: imgBomb,
                imgExplosion: imgExplosion)
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
        button.hidden = true
        txtName.hidden = true
        if SINGLE_PLAYER_MODE
        {
            newIncomingBomb()
        }
        else
        {
            gameMaster.addPlayer(gameMasterClientKey, name: txtName.text)
        }
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

