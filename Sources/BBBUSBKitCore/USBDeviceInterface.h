//
//  USBDeviceInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"

@interface USBDeviceInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBDeviceInterfaceLatest ** interface;
@property (assign, nonatomic, readonly) UInt16 vendorID;
@property (assign, nonatomic, readonly) UInt16 productID;

- (instancetype)init:(IOUSBDeviceInterfaceLatest **)interface;

@end
