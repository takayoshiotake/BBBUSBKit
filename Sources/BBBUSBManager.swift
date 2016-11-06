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

class BBBUSBManager {
    public init() {
    }
    
    public func debugPrintAllDevices() {
        var iterator: io_iterator_t = io_iterator_t()
        
        let matchingInformation = IOServiceMatching(kIOUSBDeviceClassName)
        let kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingInformation, &iterator)
        if kr != kIOReturnSuccess {
            print("Error")
            return
        }
        defer {
            IOObjectRelease(iterator)
        }
        
        while true {
            let service: io_service_t = IOIteratorNext(iterator)
            if service == 0 {
                break
            }
            defer {
                IOObjectRelease(service)
            }
            
            if let device = BBBUSBDevice(service: service) {
                print("service=\(service)")
                print("- name=\(device.name)")
                print("- path=\(device.path)")
                print("- vendorID=\(String(format: "0x%04x", device.vendorID))")
                print("- productID=\(String(format: "0x%04x", device.productID))")
            }
        }
    }
}
