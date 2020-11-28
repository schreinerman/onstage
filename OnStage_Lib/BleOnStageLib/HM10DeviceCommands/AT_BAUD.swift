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
            if (str.starts(with:"OK+Get"))
            {
                let subStr = str.components(separatedBy: ":")
                if (subStr.count > 1)
                {
                    let intStr = subStr[1]
                    if let num:Int = NumberFormatter().number(from:intStr) as? Int
                    {
                        var baudrate = 0 //default 9600 baud
                        switch(num)
                        {
                            case 0:
                                baudrate = 9600
                                break
                            case 1:
                                baudrate = 19200
                                break
                            case 2:
                                baudrate = 38400
                                break
                            case 3:
                                baudrate = 57600
                                break
                            case 4:
                                baudrate = 115200
                                break
                            case 5:
                                baudrate = 4800
                                break
                            case 6:
                                baudrate = 2400
                                break
                            case 7:
                                baudrate = 1200
                                break
                            case 8:
                                baudrate = 230400
                                break
                            default:
                                baudrate = 9600
                            
                        }
                        completion(baudrate)
                        return true
                    }
                }
            }
            return false
        })
    }
    
    public func SetBaudrate(baudrate:Int,completion: @escaping (_ response:Data) -> Void = { _ in })
    {
        var baudrateValue = 0 //default 9600 baud
        switch(baudrate)
        {
            case 9600:
                baudrateValue = 0
                break
            case 19200:
                baudrateValue = 1
                break
            case 38400:
                baudrateValue = 2
                break
            case 57600:
                baudrateValue = 3
                break
            case 115200:
                baudrateValue = 4
                break
            case 4800:
                baudrateValue = 5
                break
            case 2400:
                baudrateValue = 6
                break
            case 1200:
                baudrateValue = 7
                break
            case 230400:
                baudrateValue = 8
                break
            default:
                baudrateValue = 0
        }
        AT_BAUD_set(baudrate:baudrateValue,completion: {
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
