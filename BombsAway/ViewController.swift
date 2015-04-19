//
//  ViewController.swift
//  BombsAway
//
//  Created by Tommy Fannon on 4/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IGameClient, UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {

    var gameMaster = GameMaster.sharedInstance
    var clientKey : String!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var events: UITextView!
    @IBOutlet weak var playerPicker: UIPickerView!
    
    @IBOutlet weak var playerNameScore: UILabel!
    @IBOutlet weak var detonate: UIButton!
    @IBOutlet weak var defuse: UIButton!
    
    //id,name
    var players = [String:FBPlayer]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clientKey = self.nameOfClass
        gameMaster.registerClient(clientKey, client: self, isSinglePlayer: true)
    }

    //MARK: - UIViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = UserSettings.sharedInstance.getUserName()
        events.text = ""
        detonate.enabled = false
        defuse.enabled = false
        playerNameScore.text = ""
        playerPicker.dataSource = self
        playerPicker.delegate = self
        name.delegate = self
    }
    
    //MARK: text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    //MARK: - PickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return players.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return players.values.array[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let p = players.values.array[row]
        playerNameScore.text = "\(p.name) - \(p.score)"
    }
    
    //MARK: - Touch Detection
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
    
    //MARK - IBAction
    @IBAction func addPlayer(sender: AnyObject) {
        var count = players.values.array.filter { $0.name.rangeOfString(self.name.text) != nil }.count
        //if player exists, add a number to his name  but only persist the original in user settings
        var newName = name.text
        switch (count) {
        case 0 : UserSettings.sharedInstance.setUserName(name.text)
        case 1 : newName = "\(name.text)\(count+1)"
        default : newName = "\(name.text.sub(name.text.length))\(count+1)"
        }
            
//            let index = advance(name.text.startIndex, name.text.length)
//            let tmp = name.text.substringToIndex(index)
//            newName = "\(tmp)\(count+1)"
//        }
        gameMaster.addPlayer(clientKey, name: newName)
    }
    
    @IBAction func removePlayer(sender: AnyObject) {
    }
    
    @IBAction func defusePressed(sender: AnyObject) {
        detonate.enabled = false
        defuse.enabled = false
        gameMaster.defuse(clientKey)
    }
    
    @IBAction func detonatePressed(sender: AnyObject) {
        detonate.enabled = false
        defuse.enabled = false
        gameMaster.detonate(clientKey)
    }

    
    //MARK:  IGameClient
    func onBombAppeared(bomb : FBBomb) {
        events.text = events.text + "bomb from \(bomb.senderName) to \(bomb.receiverName) appeared\r\n"
    }
    
    func onBombDisappeared(bomb : FBBomb) {
        events.text = events.text + "\(bomb) disappeared\r\n"
    }
    
    func onPlayerAppeared(player : FBPlayer) {
        events.text = events.text + "\(player.name) joined\r\n"
        self.players[player.id] = player
        playerPicker.reloadAllComponents()
    }

    func onPlayerDisappeared(player : FBPlayer) {
        events.text = events.text + "\(player) left\r\n"
        
    }
    
    func onPlayerChanged(player : FBPlayer) {
        events.text = events.text + "\(player) changed\r\n"
    }
    
    func onBombed(bomb : FBBomb) {
        events.text = events.text + "\(bomb.receiverName) has the bomb\r\n"
        detonate.enabled = true
        defuse.enabled = true
    }
    
    func onLastPlayerDisappeared() {
        
    }
}

