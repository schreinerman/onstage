//
//  SetIO.swift
//  BleOnStageLib
//
//  Created by Manuel Schreiner on 25.11.20.
//  Copyright © 2020 io-expert.com. All rights reserved.
//

import Foundation

extension HM10DeviceAtCommand
{
    public func SetGpio(io:Int,level:Bool,completion: @escaping (_ response:Data) -> Void = { _ in })
    {
        AT_PIO_set(io: io, level: level,completion: completion)
    }
    
    public func GetGpio(io:Int,completion: @escaping (_ io:Int, _ state:Bool) -> Void = { _,_  in })
    {
        AT_PIO_get(io:io,completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            if (str.contains("PIO\(String(io))"))
            {
                if (str.last! == "1")
                {
                    completion(io,true)
                } else if (str.last! == "0")
                {
                    completion(io,false)
                }
            }
        })
    }
    
    public func AT_PIO_set(io:Int,level:Bool,completion: @escaping (_ response:Data) -> Void = { _ in })
    {
        var intLevel:Int = 0
        if (level)
        {
            intLevel = 1
        }
        let output = "AT+PIO\(String(io))\(String(intLevel))"
        self.delegate?.sendCommand(commandString: output,completion: completion)
    }
    
    public func AT_PIO_get(io:Int,completion: @escaping (_ response:Data) -> Void = { _ in })
    {
        let output = "AT+PIO\(String(io))?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
}
