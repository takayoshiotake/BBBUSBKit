//
//  BBBUSBManager.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

import Foundation
import BBBUSBKitPrivate

fileprivate let kIOUSBDeviceClassName = "IOUSBDevice"

public class BBBUSBManager {
    public init() {
    }
    
    public func listDevices() -> [BBBUSBDevice]? {
        var iterator: io_iterator_t = io_iterator_t()
        
        let matchingInformation = IOServiceMatching(kIOUSBDeviceClassName)
        let kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingInformation, &iterator)
        if kr != kIOReturnSuccess {
            print("Error")
            return nil
        }
        defer {
            IOObjectRelease(iterator)
        }
        
        var devices: [BBBUSBDevice] = []
        for service in IOServiceSequence(iterator) {
            if let device = BBBUSBDevice(service: service) { // move service
                devices.append(device)
            }
        }
        return devices
    }
}

