//
//  demohelp2.h
//  iosapp1
//
//  Created by vv on 9/9/16.
//  Copyright © 2016 Agora. All rights reserved.
//

#ifndef demohelp2_h
#define demohelp2_h


@interface KeyHelp : NSObject

+ (NSString *) createMediaKeyByAppID:(NSString*)appID
                      appCertificate:(NSString*)appCertificate
                         channelName:(NSString*)channelName
                              unixTs:(uint32_t)unixTs
                           randomInt:(uint32_t)randomInt
                                 uid:(uint32_t)uid
                           expiredTs:(uint32_t)expiredTs
;

@end

#endif /* demohelp2_h */
