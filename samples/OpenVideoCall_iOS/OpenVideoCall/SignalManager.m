//
//  SignalManager.m
//  OpenVideoCall
//
//  Created by duhaodong on 2017/2/8.
//  Copyright © 2017年 Agora. All rights reserved.
//

#import "SignalManager.h"
#import "agorasdk.h"

#import "demohelp.h"

#import <CommonCrypto/CommonDigest.h>


@interface SignalManager()

@end

static SignalManager *instance;


@implementation SignalManager

+(SignalManager*)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    return instance;
}

-(SignalManager*)initPrivate
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}


- (NSString*)MD5:(NSString*)s
{
    // Create pointer to the string as UTF8
    const char *ptr = [s UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (NSString *) calcToken:(NSString *)_appID certificate:(NSString *)certificate account:(NSString*)account expiredTime:(unsigned)expiredTime
{
   NSString * sign = [self MD5:[NSString stringWithFormat:@"%@%@%@%d", account, _appID, certificate, expiredTime]];
    return [NSString stringWithFormat:@"1:%@:%d:%@", _appID, expiredTime, sign];
}


-(NSString*)getKey:(NSString*)appid :(NSString*)cer :(NSString*)channelName uid:(uint32_t)uid_t
{
    NSString *key = [KeyHelp createMediaKeyByAppID:appid
                              appCertificate:cer
                                 channelName:channelName
                                      unixTs:time(NULL)
                                   randomInt:(rand()%256 << 24) + (rand()%256 << 16) + (rand()%256 << 8) + (rand()%256)
                                         uid:uid_t
                                   expiredTs:0
               ];
    
    return key;
}

@end
