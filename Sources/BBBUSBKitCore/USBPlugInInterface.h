//
//  USBPlugInInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"
#import "USBDeviceInterface.h"
#import "USBInterfaceInterface.h"


typedef NS_ENUM(NSUInteger, USBPlugInInterfacePlugInType) {
    USBPlugInInterfacePlugInTypeDevice,
    USBPlugInInterfacePlugInTypeInterface,
};

@interface USBPlugInInterface : NSObject

@property (assign, nonatomic, readonly) IOCFPlugInInterface ** plugInInterface;

- (instancetype)initWithService:(io_service_t)service plugInType:(USBPlugInInterfacePlugInType)plugInType;
- (USBDeviceInterface *)queryUSBDeviceInterface;
- (USBInterfaceInterface *)queryUSBInterfaceInterface;

@end
