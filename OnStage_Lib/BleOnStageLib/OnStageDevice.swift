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
        super.init()
        DispatchQueue.main.async {
            self.atCommand.GetGpio(io:2,completion: self.dataRead)
        }
    }
    
    func dataSent(response:Data)
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
    
    func stateUpdated()
    {
        if (_state == .on)
        {
            DispatchQueue.main.async {
                self.atCommand.SetGpio(io:2,level:true,completion: self.dataSent)
                //self.sendCommand(commandString: "AT+PIO21",completion: self.dataSent)
            }
        } else
        {
            DispatchQueue.main.async {
                self.atCommand.SetGpio(io:2,level:false,completion: self.dataSent)
                //self.sendCommand(commandString: "AT+PIO20",completion: self.dataSent)
            }
        }
    }
}

/*
#if os(iOS)
    import UIKit
#endif

public enum OnStageState
{
    case on,off
}
public class OnStageDevice:NSObject,ScannerDelegate
{
    #if os(iOS)
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }
    func endBackgroundTask() {
      print("Background task ended.")
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    #endif
    
    var selectedDevice:Device?
    var selectedService:CBService?
    var selectedCharacteristic:CBCharacteristic?
    
    var timeoutCounter = -1
    
    var timerConnection = Timer()
    
    var command:String = ""
    
    let scanner = Scanner()
    var upate:Bool = false
    
    @objc func updateTimer()
    {
        if (timeoutCounter > 0)
        {
            timeoutCounter -= 1
        } else if (timeoutCounter == 0)
        {
            timeoutCounter -= 1
            flush()
        }
    }
    
    func updateTimeout()
    {
        timeoutCounter = 3
    }
    
    func updateTimeoutShort()
    {
        timeoutCounter = 2
    }
    
    private var _initializing = false
    
    private var _lastState:OnStageState = .off
    
    private var _state:OnStageState = .off
        
    public var state:OnStageState
    {
        set
        {
            _state = newValue
            #if os(iOS)
            registerBackgroundTask()
            #endif
            if (_initializing == false)
            {
                stateUpdated()
            } else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    if (self._state != self._lastState)
                    {
                        #if os(iOS)
                        self.registerBackgroundTask()
                        #endif
                        self.stateUpdated()
                    }
                }
            }
        }
        get
        {
            return _lastState
        }
    }
    
    
    func stateUpdated()
    {
        if (_state == .on)
        {
            DispatchQueue.main.async {
                self.sendCommand(command: "AT+PIO21")
            }
        } else
        {
            DispatchQueue.main.async {
                self.sendCommand(command: "AT+PIO20")
            }
        }
    }
    
    func sendCommand(command:String)
    {
        self.command = command
        if (self.selectedCharacteristic != nil)
        {
            sendData(command:command)
        } else
        {
            if (_initializing == false)
            {
                _initializing = true
                scanner.start()
            }
            updateTimeout()
        }
    }
    
    func flush()
    {
        _initializing = false
        scanner.stop()
        if let dev = self.selectedDevice
        {
            dev.disconnect()
        }
        
        self.selectedDevice = nil
        self.selectedService = nil
        self.selectedCharacteristic = nil
        #if os(iOS)
        endBackgroundTask()
        #endif
        
    }
    
    override public init() {
        super.init()
        
        self.timerConnection = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        scanner.delegate = self
        //stateUpdated()
    }
    
    func scanner(_ scanner: Scanner, didUpdateDevices: [Device]) {
        self.upate = true
        for dev in didUpdateDevices
        {
            if (dev.friendlyName == "HMSoft") && (selectedDevice == nil)
            {
                self.selectedDevice = dev
                self.selectedDevice?.delegate = self
                selectedDevice?.connect()
                updateTimeout()
            }
        }
    }
}



extension OnStageDevice : DeviceDelegate {
    func deviceDidConnect(_ device: Device) {

    }
    
    func deviceDidDisconnect(_ device: Device) {
        self.selectedDevice = nil
        self.selectedService = nil
        self.selectedCharacteristic = nil
    }
    
    func deviceDidUpdateName(_ device: Device) {
    
    }
    
    func device(_ device: Device, updated services: [CBService]) {
        for service in services {
            if service.uuid == CBUUID(string: "FFE0") {
                self.selectedService = service
                device.discoverCharacteristics(for: service)
                updateTimeout()
            }
        }
    }
    
    func device(_ device: Device, updated characteristics: [CBCharacteristic], for service: CBService) {
       
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "FFE1") {
                    if characteristic.properties.contains(.read) {
                        device.read(characteristic: characteristic)
                    }
                    
                    self.selectedCharacteristic = characteristic
                    updateTimeout()
                    scanner.stop()
                    sendData(command: self.command)
                }
            }
    }
    
    func device(_ device: Device, updatedValueFor characteristic: CBCharacteristic) {
        /*
        if characteristic == selectedCharacteristic {
            characteristicUpdatedDate = Date()
            refreshCharacteristicDetail()
        }
         */
    }
    
    func sendData(command:String)
    {
        if let characteristic = self.selectedCharacteristic {
            var writeType = CBCharacteristicWriteType.withResponse
            if (!characteristic.properties.contains(.write)) {
                writeType = .withoutResponse
            }
            let data = command.data(using: String.Encoding.ascii)
            _lastState = _state
            selectedDevice?.write(data: data!, for: characteristic, type: writeType)
            _initializing = false
            updateTimeoutShort()
        }
    }
}
 */

