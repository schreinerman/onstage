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
    public func SetMultipleGpios(value:Int,completion: @escaping () -> Void = { })
    {
        AT_MPIO_set(value:value,completion: {
            response in
            completion()
            return true
        })
    }
    
    
    public func GetMultipleGpio() -> Int
    {
        var out:Int = 0
        
        waitForAsyncProcess(execute: {
            self.GetMultipleGpio(completion:{
                states in
                out = states
            })
        })
       
        return out
    }
    
    public func GetMultipleGpio(completion: @escaping (_ states:Int) -> Void = { _  in })
    {
        AT_MPIO_get(completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            if (str.starts(with:"OK+Get"))
            {
                let subStr = str.components(separatedBy: ":")
                if (subStr.count > 1)
                {
                    let hexString = subStr[1]
                    if let value = UInt32(hexString, radix: 16) {
                        completion(Int(value))
                        return true
                    }
                }
            }
            return false
        })
    }
    
    public func AT_MPIO_set(value:Int,completion: @escaping (_ response:Data) -> Bool = { _ in return true })
    {
        let hexStr = String(format:"%03X", value)
        let output = "AT+MPIO\(hexStr)"
        self.delegate?.sendCommand(commandString: output,completion: completion)
    }
    
    public func AT_MPIO_get(completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let output = "AT+MPIO?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
}
