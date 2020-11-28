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
    public func GetBaudrate(completion: @escaping (_ response:Int) -> Void = { _ in })
    {
        AT_BAUD_get(completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            completion(Int(str) ?? 0)
            return true
        })
    }
    
    public func SetBaudrate(baudrate:Int,completion: @escaping (_ response:Data) -> Void = { _ in })
    {
        AT_BAUD_set(baudrate:baudrate,completion: {
            response in
            completion(response)
            return true
        })
    }
    
    public func AT_BAUD_get(completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let output = "AT+BAUD?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
    
    public func AT_BAUD_set(baudrate:Int,completion: @escaping (_ response:Data) -> Bool = { _ in  return true})
    {
        let output = "AT+BAUD\(String(baudrate))"
        self.delegate?.sendCommand(commandString: output,completion: completion)
    }
}
