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
            exit(0)
        }
        repeat {
            let service: io_service_t = IOIteratorNext(iterator)
            if service == 0 {
                break
            }
            
            let name: String
            let path: String
            
            let nameBytes = UnsafeMutablePointer<Int8>.allocate(capacity: MemoryLayout<io_name_t>.size)
            IORegistryEntryGetName(service, nameBytes)
            name = String(cString: nameBytes)
            nameBytes.deallocate(capacity: MemoryLayout<io_name_t>.size)
            
            let pathBytes = UnsafeMutablePointer<Int8>.allocate(capacity: MemoryLayout<io_name_t>.size)
            IORegistryEntryGetPath(service, kIOUSBPlane, pathBytes)
            path = String(cString: pathBytes)
            pathBytes.deallocate(capacity: MemoryLayout<io_name_t>.size)
            
            print("service=\(service)")
            print("- name=\(name)")
            print("- path=\(path)")
            
            if let plugInInterface = USBPlugInInterface(service) {
                if let interface = plugInInterface.queryInterface() {
                    print("- vendorID=\(String(format: "0x%04x", interface.vendorID))")
                    print("- productID=\(String(format: "0x%04x", interface.productID))")
                }
            }
            
            IOObjectRelease(service)
        } while true
        
        IOObjectRelease(iterator)
    }
}
