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
    public func Reset(completion: @escaping () -> Void = { })
    {
        AT_RESET(completion: {
            _ in
            completion()
            return true
        })
    }
    
    public func AT_RESET(completion: @escaping (_ response:Data) -> Bool = { _ in return true})
    {
        let output = "AT+RESET"
        self.delegate?.sendCommand(commandString: output,waitForResponse:true, completion: completion)
    }
}
