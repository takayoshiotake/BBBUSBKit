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
        
        for service in IOServiceSequence(iterator) {
            if let device = BBBUSBDevice(service: service) { // move service
                print("service=\(service)")
                print("- name=\(device.name)")
                print("- path=\(device.path)")
                print("- vendorID=\(String(format: "0x%04x", device.vendorID))")
                print("- productID=\(String(format: "0x%04x", device.productID))")
            }
        }
    }
}

#if false // because "Swift Compiler Error" has occured
extension io_iterator_t: Sequence {
    // Swift Compiler Error: Method 'makeIterator()' must be declared public because it matches a requirement in public protocol 'Sequence'
    // Swift Compiler Error: Method must be declared fileprivate because its result uses a fileprivate type
    fileprivate func makeIterator() -> IOServiceGenerator {
        return IOServiceGenerator(self)
    }
}
#else
fileprivate class IOServiceSequence: Sequence {
    let iterator: io_iterator_t
    
    init(_ iterator: io_iterator_t) {
        self.iterator = iterator
    }
    
    fileprivate func makeIterator() -> IOServiceGenerator {
        return IOServiceGenerator(iterator)
    }
}
#endif

fileprivate class IOServiceGenerator: IteratorProtocol {
    let iterator: io_iterator_t
    
    init(_ iterator: io_iterator_t) {
        self.iterator = iterator
    }
    
    func next() -> io_service_t? {
        let service = IOIteratorNext(iterator)
        if service == 0 {
            return nil
        }
        return service
    }
}
