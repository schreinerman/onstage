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
    public func GetAdc(io:Int,completion: @escaping (_ response:String) -> Void = { _ in })
    {
        AT_ADC(io:io,completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            completion(str)
        })
    }
    

    
    public func AT_ADC(io:Int,completion: @escaping (_ response:Data) -> Void = { _ in })
    {
        let output = "AT+ADC\(String(io))?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
    
}
