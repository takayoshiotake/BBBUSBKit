//
//  BBBUSBDescriptor.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/11.
//  Copyright © 2016 OTAKE Takayoshi. All rights reserved.
//

import Cocoa

public struct USBDeviceDescriptor {
    public let bLength: UInt8
    public let bDescriptorType: UInt8
    public let bcdUSB: UInt16
    public let bDeviceClass: UInt8
    public let bDeviceSubClass: UInt8
    public let bDeviceProtocol: UInt8
    public let bMaxPacketSize0: UInt8
    public let idVendor: UInt16
    public let idProduct: UInt16
    public let bcdDevice: UInt16
    public let iManufacturer: UInt8
    public let iProduct: UInt8
    public let iSerialNumber: UInt8
    public let bNumConfigurations: UInt8
    
    public let manufacturerString: String?
    public let productString: String?
    public let serialNumberString: String?
}

public struct USBConfigurationDescriptor {
    public let bLength: UInt8
    public let bDescriptorType: UInt8
    public let wTotalLength: UInt16
    public let bNumInterfaces: UInt8
    public let bConfigurationValue: UInt8
    public let iConfiguration: UInt8
    public let bmAttributes: UInt8
    public let bMaxPower: UInt8
    
    public let configurationString: String?
    
    public let interfaces: [USBInterfaceDescriptor]
}

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
    
    public let interfaceString: String?
    
    public let endpoints: [USBEndpointDescriptor]
}

public struct USBEndpointDescriptor {
    public let bLength: UInt8
    public let bDescriptorType: UInt8
    public let bEndpointAddress: UInt8
    public let bmAttributes: UInt8
    public let wMaxPacketSize: UInt16
    public let bInterval: UInt8
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
