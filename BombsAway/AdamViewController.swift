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
    @IBOutlet weak var lblScore: UILabel!
    var lblMessage : UILabel!
    
    var i = 0
    var bomb : Bomb?
    let gameMaster = GameMaster.sharedInstance
    var gameMasterClientKey : String!
    var players = [String: FBPlayer]()
    
    let SINGLE_PLAYER_MODE = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if (!SINGLE_PLAYER_MODE)
        {
            gameMasterClientKey = self.nameOfClass
            gameMaster.registerClient(gameMasterClientKey, client: self)
        }
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
            //showMessage("Here it comes!")
        }
    }
    
    @IBAction func tapBomb(sender: UIGestureRecognizer) {
        if (bomb != nil)
        {
            let p = sender.locationInView(self.view)
            bomb!.tryDiffuseAndSend(p)
        }
    }
    
    // MARK: Messages
    private func showMessage(message : String!)
    {
        lblMessage.removeAllAnimations(placeInCurrentPosition: false)
        lblMessage.alpha = 1
        lblMessage.text = message
        lblMessage.hidden = false
        lblMessage.fadeOut(duration: 1.5, delay: 0, completion: { (complete) -> Void in
            if (complete)
            {
                self.lblMessage.hidden = true;
            }
        }
        )
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
        showMessage("\(bomb.senderName) bombed \(bomb.receiverName)")
    }
    func onBombDisappeared(bomb: FBBomb) {
        
    }
    func onPlayerAppeared(player: FBPlayer) {
        players[player.id] = player
        updateScore()
        showMessage("\(player.name) has joined")
    }
    func onPlayerDisappeared(player: FBPlayer) {
        players.removeValueForKey(player.id)
        updateScore()
        showMessage("\(player.name) has left")
    }
    func onPlayerChanged(player : FBPlayer) {
        players[player.id] = player
        updateScore()
    }

    func onLastPlayerDisappeared() {
        bomb?.diffuse()
    }
    
    private func updateScore()
    {
        var s = ""
        for x in players
        {
            s += "\(x.1.name): \(x.1.score) "
        }
        lblScore.text = s;
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
        
        lblMessage = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 20, 30))
        lblMessage.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height - 40)
        lblMessage.textAlignment = .Center
        lblMessage.textColor = UIColor.purpleColor()
        lblMessage.hidden = true
        self.view.addSubview(lblMessage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

}

