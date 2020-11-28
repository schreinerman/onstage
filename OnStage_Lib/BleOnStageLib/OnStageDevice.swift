//
//  OnStageDevice.swift
//  OnStageGui
//
//  Created by Manuel Schreiner on 20.11.20.
//  Copyright © 2020 io-expert.com. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum OnStageState
{
    case on,off
}

public protocol OnStageDeviceDelegate
{
    func onStage(didUpdatedState state:Bool)
}

public class OnStageDevice:HM10Device
{
    private var updateTimer = Timer()
    
    private var _lastState:OnStageState = .off
    
    private var _state:OnStageState = .off
    
    public var delegate:OnStageDeviceDelegate?
        
    public var state:OnStageState
    {
        set
        {
            _state = newValue
            stateUpdated()
        }
        get
        {
            return _lastState
        }
    }
    
    override public init() {
        super.init(name:"ON-STAGE")
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(requestStatus),userInfo: nil,repeats: true)
        self.dispatchAsync {
            self.atCommand.GetGpio(io:2,completion: self.dataRead)
        }
    }
    
    func dataSent(io:Int,response:Data)
    {
        _lastState = _state
    }
    
    func dataRead(io:Int,state:Bool)
    {
        if (io == 2)
        {
            if (state)
            {
                _state = .on
            } else
            {
                _state = .off
            }
            _lastState = _state
        }
        delegate?.onStage(didUpdatedState: state)
    }
    
    @objc func requestStatus()
    {
        self.dispatchAsync {
            self.atCommand.GetGpio(io:2,completion: self.dataRead)
        }
    }
    
    public func reload()
    {
        self.dispatchAsync {
            self.atCommand.GetGpio(io:2,completion: self.dataRead)
        }
    }
    
    func stateUpdated()
    {
        if (_state == .on)
        {
            self.dispatchAsync {
                self.atCommand.SetGpio(io:2,level:true,completion: self.dataSent)
            }
        } else
        {
            self.dispatchAsync {
                self.atCommand.SetGpio(io:2,level:false,completion: self.dataSent)
            }
        }
    }
}
