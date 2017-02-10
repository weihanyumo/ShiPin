//
//  help.m
//  iosapp1
//
//  Created by vv on 9/9/16.
//  Copyright © 2016 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "demohelp.h"

#include "DynamicKey4.h"

@interface KeyHelp ()
@end

@implementation KeyHelp

+ (NSString *) createMediaKeyByAppID:(NSString*)appID
         appCertificate:(NSString*)appCertificate
            channelName:(NSString*)channelName
                 unixTs:(uint32_t)unixTs
              randomInt:(uint32_t)randomInt
                    uid:(uint32_t)uid
              expiredTs:(uint32_t)expiredTs
{
    std::string x = agora::tools::DynamicKey4::generateMediaChannelKey(
                                                                       [appID UTF8String],
                                                                       [appCertificate UTF8String],
                                                                       [channelName UTF8String],
                                                                       unixTs,
                                                                       randomInt,
                                                                       uid,
                                                                       expiredTs).c_str();
    
    return [NSString stringWithCString:x.c_str()
                              encoding:NSUTF8StringEncoding] ;
}

@end