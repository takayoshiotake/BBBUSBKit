//
//  BBBUSBInterface.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

import Foundation
import BBBUSBKitPrivate

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
            // TODO:
            return USBInterfaceDescriptor()
        }
    }
}
