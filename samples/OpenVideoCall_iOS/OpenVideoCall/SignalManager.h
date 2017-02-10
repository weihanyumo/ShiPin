//
//  SignalManager.h
//  OpenVideoCall
//
//  Created by duhaodong on 2017/2/8.
//  Copyright © 2017年 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "agorasdk.h"

@interface SignalManager : NSObject

+(SignalManager*)shareManager;

- (NSString *) calcToken:(NSString *)_appID certificate:(NSString *)certificate account:(NSString*)account expiredTime:(unsigned)expiredTime;
-(NSString*)getKey:(NSString*)appid :(NSString*)cer :(NSString*)channelName uid:(uint32_t)uid_t;

@end
