//
//  BBBUSBKitCore.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

#import "BBBUSBKitCore.h"

@implementation NSError (BBBUSBKit_IOReturn)
+ (NSError *)BBBUSBKitErrorWithIOReturn:(IOReturn)code {
    return [NSError errorWithDomain:kBBBUSBKitIOReturnErrorDomain code:code userInfo:nil];
}
@end
