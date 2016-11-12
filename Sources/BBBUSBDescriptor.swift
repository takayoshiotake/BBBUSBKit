//
//  BBBUSBDescriptor.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/11.
//  Copyright © 2016 OTAKE Takayoshi. All rights reserved.
//

import Cocoa

public struct USBDeviceDescriptor {
    public var bLength: UInt8 = 0
    public var bDescriptorType: UInt8 = 0
    public var bcdUSB: UInt16 = 0
    public var bDeviceClass: UInt8 = 0
    public var bDeviceSubClass: UInt8 = 0
    public var bDeviceProtocol: UInt8 = 0
    public var bMaxPacketSize0: UInt8 = 0
    public var idVendor: UInt16 = 0
    public var idProduct: UInt16 = 0
    public var bcdDevice: UInt16 = 0
    public var iManufacturer: UInt8 = 0
    public var iProduct: UInt8 = 0
    public var iSerialNumber: UInt8 = 0
    public var bNumConfigurations: UInt8 = 0
    
    public var manufacturerString: String? = nil
    public var productString: String? = nil
    public var serialNumberString: String? = nil
    
    init() {
    }
}

public struct USBConfigurationDescriptor {
    public var bLength: UInt8 = 0
    public var bDescriptorType: UInt8 = 0
    public var wTotalLength: UInt16 = 0
    public var bNumInterfaces: UInt8 = 0
    public var bConfigurationValue: UInt8 = 0
    public var iConfiguration: UInt8 = 0
    public var bmAttributes: UInt8 = 0
    public var bMaxPower: UInt8 = 0
    
    public var configurationString: String? = nil
    public var interfaces: [USBInterfaceDescriptor] = []
    
    init() {
    }
}

public struct USBInterfaceDescriptor {
    public var bLength: UInt8 = 0
    public var bDescriptorType: UInt8 = 0
    public var bInterfaceNumber: UInt8 = 0
    public var bAlternateSetting: UInt8 = 0
    public var bNumEndpoints: UInt8 = 0
    public var bInterfaceClass: UInt8 = 0
    public var bInterfaceSubClass: UInt8 = 0
    public var bInterfaceProtocol: UInt8 = 0
    public var iInterface: UInt8 = 0
    
    public var interfaceString: String? = nil
    public var endpoints: [USBEndpointDescriptor] = []
    
    init() {
    }
}

public struct USBEndpointDescriptor {
    public var bLength: UInt8 = 0
    public var bDescriptorType: UInt8 = 0
    public var bEndpointAddress: UInt8 = 0
    public var bmAttributes: UInt8 = 0
    public var wMaxPacketSize: UInt16 = 0
    public var bInterval: UInt8 = 0
    
    init() {
    }
}

public enum USBDescriptorType : UInt8 {
    case device = 1
    case configuration = 2
    case string = 3
    case interface = 4
    case endpoint = 5
    case deviceQualifier = 6
    case otherSpeedConfiguration = 7
    case interfacePower = 8
}
