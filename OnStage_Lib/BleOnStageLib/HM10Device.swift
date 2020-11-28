//
//  HM10Device.swift
//  BleOnStageLib
//
//  Created by Manuel Schreiner on 25.11.20.
//  Copyright © 2020 io-expert.com. All rights reserved.
//

import Foundation
import CoreBluetooth
#if os(iOS)
    import UIKit
#endif

public struct HM10DeviceCommand
{
    public var commandString:String = ""
    public var waitForResponse:Bool = false
    public var completion: (_ response:Data) -> Bool
    public var commandResponseString = "" //used to describe a valid response
}

public struct HM10DeviceCommandQueue
{
    var items = [HM10DeviceCommand]()
    mutating func enqueue(_ item: HM10DeviceCommand) {
        items.append(item)
    }
    mutating func enqueue(command: String) {
        let item = HM10DeviceCommand(commandString:command,waitForResponse: false,completion: {_ in return true})
        items.append(item)
    }
    
    mutating func dequeue() -> HM10DeviceCommand {
        return items.removeFirst()
    }
}

public class HM10DeviceAtCommand:NSObject
{
    override public init() {
        super.init()
    }
    var delegate:HM10Device?
}

public class HM10Device:NSObject,ScannerDelegate
{
    public var name:String = "ON-STAGE" //HMSoft
    public var serviceString:String = "FFE0"
    public var characteristicString:String = "FFE1"
        
    public var autoOpen:Bool = true
    public var reties = 4
    public var keepOpenTimeout = 2
    public var timeout = 2
    public var processingCommand:Bool = false
    
    public var atCommand:HM10DeviceAtCommand = HM10DeviceAtCommand()
    
    private var tried = 0
    
    private var selectedDevice:Device?
    private var selectedService:CBService?
    private var selectedCharacteristic:CBCharacteristic?
    private var selectedCharacteristicRead:CBCharacteristic?
    
    private var timeoutCounter = -1
    private var timerConnection = Timer()
    private var queueTimer = Timer()
    
    private var initializing = false
    private var connected = false
    
    private var commandQueue:HM10DeviceCommandQueue = HM10DeviceCommandQueue()
    
    private var command:HM10DeviceCommand = HM10DeviceCommand(completion:{_ in return true})
    
    public let dispatch = DispatchQueue(label: "HM10Device")

    private let scanner = Scanner()
    
    #if os(iOS)
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }
    private func endBackgroundTask() {
      print("Background task ended.")
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    #endif
    
    public init(name:String) {
        super.init()
        self.name = name
        setup()
    }
    
    override public init() {
        super.init()
        setup()
    }
    
    func setup()
    {
        atCommand.delegate = self
        
        self.timerConnection = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        scanner.delegate = self
    }
    
    @objc private func updateTimer()
    {
        if (timeoutCounter > 0)
        {
            timeoutCounter -= 1
        } else if (timeoutCounter == 0)
        {
            if (self.tried > 0) && (commandQueue.items.count > 0)
            {
                self.tried -= 1
                timeoutCounter = self.timeout
                sendCommandDirect(command:command)
            } else
            {
                timeoutCounter -= 1
                flush()
            }
            
        }
    }
    
    public func sendCommand(commandString:String,waitForResponse: Bool = false, completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let command = HM10DeviceCommand(commandString: commandString, waitForResponse: waitForResponse, completion: completion)
        sendCommand(command:command)
    }
    
    public func sendCommand(command:HM10DeviceCommand)
    {
        commandQueue.enqueue(command)
        if (processingCommand == false) && (((self.selectedCharacteristic == nil) && (initializing == false))
            || (commandQueue.items.count == 1))
        {
            dequeueCommand()
        }
    }
    
    private func dequeueCommand()
    {
        if (commandQueue.items.count > 0)
        {
            #if os(iOS)
            registerBackgroundTask()
            #endif
            self.tried = self.reties
            sendCommandDirect(command:commandQueue.dequeue())
        }
    }
    
    private func sendCommandDirect(command:HM10DeviceCommand)
    {
        self.processingCommand = true
        self.command = command
        if (self.selectedCharacteristic != nil)
        {
            timeoutCounter = timeout
            sendData(command:command.commandString)
        } else
        {
            if (initializing == false)
            {
                initializing = true
                timeoutCounter = 10
                scanner.start()
            }
        }
    }
    
    private func flush()
    {
        initializing = false
        scanner.stop()
        if let dev = self.selectedDevice
        {
            dev.disconnect()
        }
        
        self.selectedDevice = nil
        self.selectedService = nil
        self.selectedCharacteristic = nil
        self.selectedCharacteristicRead = nil
        self.processingCommand = false
        #if os(iOS)
        endBackgroundTask()
        #endif
    }
    
    func scanner(_ scanner: Scanner, didUpdateDevices: [Device]) {
        for dev in didUpdateDevices
        {
            if (dev.friendlyName == self.name) && (selectedDevice == nil)
            {
                self.selectedDevice = dev
                self.selectedDevice?.delegate = self
                if (self.connected == false)
                {
                    selectedDevice?.connect()
                }
                self.timeoutCounter = self.timeout
            }
        }
    }
}

extension HM10Device : DeviceDelegate {
    func deviceDidConnect(_ device: Device) {
        self.connected = true
    }
    
    func deviceDidDisconnect(_ device: Device) {
        self.selectedDevice = nil
        self.selectedService = nil
        self.selectedCharacteristic = nil
        self.connected = false
    }
    
    func deviceDidUpdateName(_ device: Device) {
    
    }
    
    func device(_ device: Device, updated services: [CBService]) {
        for service in services {
            if service.uuid == CBUUID(string: self.serviceString) {
                self.selectedService = service
                device.discoverCharacteristics(for: service)
                self.timeoutCounter = self.timeout
            }
        }
    }
    
    func device(_ device: Device, updated characteristics: [CBCharacteristic], for service: CBService) {
       
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: self.characteristicString) {
                    if characteristic.properties.contains(.read) {
                        device.read(characteristic: characteristic)
                        selectedDevice?.setNotify(true, for: characteristic)
                        self.selectedCharacteristicRead = characteristic
                    }
                    if characteristic.properties.contains(.writeWithoutResponse) || characteristic.properties.contains(.write) {
                        self.selectedCharacteristic = characteristic
                    }
                }
            }
            self.timeoutCounter = self.timeout
            scanner.stop()
            if (!self.command.commandString.isEmpty)
            {
                self.dispatch.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.sendData(command: self.command.commandString)
                })
            }
    }
    
    func device(_ device: Device, updatedValueFor characteristic: CBCharacteristic) {
        if let data = characteristic.value
        {
            if !((data.count == 1) && (data[0] == 0))
            {
                let str = String(decoding: data, as: UTF8.self)
                if (str.contains("OK+"))
                {
                    let commandSuccess = self.command.completion(data)
                    if (commandSuccess)
                    {
                        self.command = HM10DeviceCommand(completion: { _ in return true})
                        self.processingCommand = false
                        
                        if (commandQueue.items.count > 0)
                        {
                            self.dispatch.async {
                                self.dequeueCommand()
                            }
                            timeoutCounter = timeout
                        }
                        else
                        {
                            timeoutCounter = keepOpenTimeout
                        }
                    }
                }
            }
        }
    }
    
    func sendData(command:String)
    {
        if let characteristic = self.selectedCharacteristic {
            print("Sending Command:\(command)")
            var writeType = CBCharacteristicWriteType.withResponse
            if (!characteristic.properties.contains(.write)) {
                writeType = .withoutResponse
            }
            let data = command.data(using: String.Encoding.ascii)
            selectedDevice?.write(data: data!, for: characteristic, type: writeType)
            initializing = false
            if (self.command.waitForResponse == false)
            {
                let _ = self.command.completion(Data())
                self.command = HM10DeviceCommand(completion: { _ in return true})
                self.processingCommand = false
                if (commandQueue.items.count > 0)
                {
                    self.dispatch.async {
                        self.dequeueCommand()
                    }
                    timeoutCounter = timeout
                }
                else
                {
                    timeoutCounter = keepOpenTimeout
                }
            }
            
            
            
        }
    }
}

