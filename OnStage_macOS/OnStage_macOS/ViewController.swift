//
//  ViewController.swift
//  OnStageGui
//
//  Created by Manuel Schreiner on 20.11.20.
//  Copyright © 2020 io-expert.com. All rights reserved.
//

import Cocoa
import BleOnStageLib

class ViewController: NSViewController {

    @IBOutlet weak var onStageButton: NSButton!
    @IBOutlet weak var onStageImage: NSImageView!
    
    var onStageDev = OnStageDevice()
    
    let defaults = UserDefaults.standard
    
    var counter = 0
    
    var lastStatus = false
    
    var blinkTimer = Timer()
    
    
    @IBAction func onStageButton_Changed(_ sender: Any) {
        lastStatus = (onStageButton.state == .on)
        updateStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(blinkTimer_Update), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }

    @objc func blinkTimer_Update()
    {
        counter += 1
        if ((lastStatus && (onStageDev.state == .off)) || (!lastStatus && (onStageDev.state == .on)))
        {
            if (counter % 2 == 0)
            {
                onStageImage.image = NSImage(named:"onstage")
            } else
            {
                onStageImage.image = NSImage(named:"offstage")
            }
        } else
        {
            if (lastStatus)
            {
                onStageImage.image = NSImage(named:"onstage")
            }
            else
            {
                onStageImage.image = NSImage(named:"offstage")
            }
        }
    }
    
    func updateStatus()
    {

        if (lastStatus)
        {
            onStageDev.state = .on
            onStageImage.image = NSImage(named:"onstage")
        }
        else
        {
            onStageDev.state = .off
            onStageImage.image = NSImage(named:"offstage")
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

