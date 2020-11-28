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
    public func SetGpio(io:Int,level:Bool,completion: @escaping (_ io:Int, _ response:Data) -> Void = { _ , _ in })
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
        
        let dpGroup = DispatchGroup()
        
        dpGroup.enter()
        self.delegate?.dispatch.async {
            self.GetGpio(io:io,completion:{
                io, state in
                out = state
                dpGroup.leave()
            })
        }
        let _ = dpGroup.wait(timeout: .now() + 5)
        return out
    }
    
    public func GetGpio(io:Int,completion: @escaping (_ io:Int, _ state:Bool) -> Void = { _,_  in })
    {
        AT_PIO_get(io:io,completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            if (str.starts(with:"OK+PIO\(String(io))"))
            {
                if (str.last! == "1")
                {
                    completion(io,true)
                } else if (str.last! == "0")
                {
                    completion(io,false)
                }
                return true
            }
            return false
        })
    }
    
    public func AT_PIO_set(io:Int,level:Bool,completion: @escaping (_ response:Data) -> Bool = { _ in return true })
    {
        var intLevel:Int = 0
        if (level)
        {
            intLevel = 1
        }
        let output = "AT+PIO\(String(io))\(String(intLevel))"
        self.delegate?.sendCommand(commandString: output,completion: completion)
    }
    
    public func AT_PIO_get(io:Int,completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let output = "AT+PIO\(String(io))?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
}
