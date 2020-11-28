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
    public func GetAdc(io:Int) -> CGFloat
    {
        var out:CGFloat = -1.0
        
        let dpGroup = DispatchGroup()
        dpGroup.enter()
        self.delegate?.dispatch.async {
            self.GetAdc(io:io,completion:{
                response in
                out = response
                dpGroup.leave()
            })
        }
        let _ = dpGroup.wait(timeout: .now() + 5)
        return out
    }
    
    public func GetAdc(io:Int,completion: @escaping (_ response:CGFloat) -> Void = { _ in })
    {
        AT_ADC(io:io,completion: {
            response in
            let str = String(decoding: response, as: UTF8.self)
            if (str.starts(with:"OK+ADC\(String(io))"))
            {
                let subStr = str.components(separatedBy: ":")
                if (subStr.count > 1)
                {
                    let floatString = subStr[1].replacingOccurrences(of: ".", with:",")
                    if let num:CGFloat = NumberFormatter().number(from:floatString) as? CGFloat
                    {
                        completion(num)
                        return true
                    }
                }
            }
            return false
        })
    }
    

    
    public func AT_ADC(io:Int,completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let output = "AT+ADC\(String(io))?"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
    
}
