//
//  BBBUSBInterface.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

import Foundation
import BBBUSBKitPrivate

public struct USBInterfaceDescriptor {
    public let bLength: UInt8
    public let bDescriptorType: UInt8
    public let bInterfaceNumber: UInt8
    public let bAlternateSetting: UInt8
    public let bNumEndpoints: UInt8
    public let bInterfaceClass: UInt8
    public let bInterfaceSubClass: UInt8
    public let bInterfaceProtocol: UInt8
    public let iInterface: UInt8
}

public class BBBUSBInterface {
    let service: io_service_t
    let interface: USBInterfaceInterface
    weak var device: BBBUSBDevice!
    
    init?(service: io_service_t, device: BBBUSBDevice) {
        self.service = service

        guard let plugInInterface = USBPlugInInterface(service: service, plugInType: .interface), let interface = plugInInterface.queryUSBInterfaceInterface(device.device) else {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
        self.interface = interface
        self.device = device
    }
    
    deinit {
        IOObjectRelease(service)
    }
    
    public var interfaceDescriptor: USBInterfaceDescriptor {
        get {
            var interfaceDescriptor = interface.interfaceDescriptor
            return withUnsafePointer(to: &interfaceDescriptor) {
                $0.withMemoryRebound(to: USBInterfaceDescriptor.self, capacity: 1) {
                    $0.pointee
                }
            }
        }
    }
}
