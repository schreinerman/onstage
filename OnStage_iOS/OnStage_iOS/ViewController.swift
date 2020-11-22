//
//  ViewController.swift
//  On-Stage
//
//  Created by Manuel Schreiner on 20.11.20.
//  Copyright © 2020 io-expert.com. All rights reserved.
//

import UIKit
import BleOnStageLib

class ViewController: UIViewController {
    var onStageDev = OnStageDevice()
    let defaults = UserDefaults.standard
    
    var counter = 0
    
    var lastStatus = false
    
    var blinkTimer = Timer()
    
    @IBOutlet weak var onStageEnable: UISwitch!
    @IBOutlet weak var onStageImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(blinkTimer_Update), userInfo: nil, repeats: true)
        
        
        if let status = self.defaults.object(forKey:"LastStatus")
        {
            self.lastStatus = status as! Bool
            self.onStageEnable.setOn(self.lastStatus, animated: true)
            if (lastStatus)
            {
                onStageImage.image = UIImage(named:"onstage")
            }
            else
            {
                onStageImage.image = UIImage(named:"offstage")
            }
            if ((lastStatus && (onStageDev.state == .off)) || (!lastStatus && (onStageDev.state == .on)))
            {
                updateStatus()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func blinkTimer_Update()
    {
        counter += 1
        if ((lastStatus && (onStageDev.state == .off)) || (!lastStatus && (onStageDev.state == .on)))
        {
            if (counter % 2 == 0)
            {
                onStageImage.image = UIImage(named:"onstage")
            } else
            {
                onStageImage.image = UIImage(named:"offstage")
            }
        } else
        {
            if (lastStatus)
            {
                onStageImage.image = UIImage(named:"onstage")
            }
            else
            {
                onStageImage.image = UIImage(named:"offstage")
            }
        }
    }
    
    func updateStatus()
    {
        defaults.set(lastStatus,forKey: "LastStatus")
        if (lastStatus)
        {
            onStageDev.state = .on
            onStageImage.image = UIImage(named:"onstage")
        }
        else
        {
            onStageDev.state = .off
            onStageImage.image = UIImage(named:"offstage")
        }
    }

    @IBAction func onStageEnable_Changed(_ sender: Any) {
        lastStatus = onStageEnable.isOn
        updateStatus()
    }
    
}

