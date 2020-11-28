//
//  SetIO.swift
//  BleOnStageLib
//
//  Created by Manuel Schreiner on 25.11.20.
//  Copyright © 2020 io-expert.com. All rights reserved.
//

import Foundation

public enum GpioPwm:Int
{
    case on = 0
    case off = 1
    case Pwm100ms = 2
    case Pwm200ms = 3
    case Pwm300ms = 4
    case Pwm400ms = 5
    case Pwm500ms = 6
    case Pwm600ms = 7
    case Pwm700ms = 8
    case Pwm800ms = 9
}
extension HM10DeviceAtCommand
{
    public func SetGpio(io:Int,level:Bool,completion: @escaping (_ io:Int, _ response:Data) -> Void = { _ , _ in })
    {
        var intLevel:GpioPwm = .off
        if (level)
        {
            intLevel = .on
        }
        AT_PIO_set(io: io, level: intLevel,completion: {
            response in
            completion(io,response)
            return true
        })
    }
    
    public func SetGpio(io:Int,level:GpioPwm,completion: @escaping (_ io:Int, _ response:Data) -> Void = { _ , _ in })
    {
        AT_PIO_set(io: io, level: level,completion: {
            response in
            completion(io,response)
            return true
        })
    }
    
    public func GetGpio(io:Int) -> Bool
    {
        var out:Bool = false
        
        waitForAsyncProcess(execute: {
            self.GetGpio(io:io,completion:{
                io, state in
                out = state
            })
        })
       
        return out
    }
    
    public func GetGpio(io:Int,completion: @escaping (_ io:Int, _ state:Bool) -> Void = { _,_  in })
    {
        AT_PIO_get(io:io,completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            if (str.starts(with:"OK+PIO\(String(io))"))
            {
                if (str.last! == "0")
                {
                    completion(io,false)
                } else
                {
                    completion(io,true)
                }
                return true
            }
            return false
        })
    }
    
    public func GetGpio(io:Int,completion: @escaping (_ io:Int, _ state:GpioPwm) -> Void = { _,_  in })
    {
        AT_PIO_get(io:io,completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            if (str.starts(with:"OK+PIO\(String(io))"))
            {
                let lastChar = String(str.last!)
                let gpioState = GpioPwm(rawValue:Int(lastChar) ?? 0)!
                completion(io,gpioState)
                return true
            }
            return false
        })
    }
    
    public func AT_PIO_set(io:Int,level:GpioPwm,completion: @escaping (_ response:Data) -> Bool = { _ in return true })
    {
        let intLevel:Int = level.rawValue
        let output = "AT+PIO\(String(io))\(String(intLevel))"
        self.delegate?.sendCommand(commandString: output,completion: completion)
    }
    
    public func AT_PIO_get(io:Int,completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let output = "AT+PIO\(String(io))?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
}
