//
//  MKPlistDataManager.h
//  SocialElectricity
//
//  Created by zhengmiaokai on 15/9/3.
//  Copyright (c) 2015年 JD.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PlistDataStore  [MKPlistDataManager shareInstance]

@interface MKPlistDataManager : NSObject

+ (instancetype)shareInstance;

- (instancetype)initWithFileName:(NSString *)fileName;

- (void)setObject:(id)object forKey:(NSString*)key;

- (id)objectForKey:(NSString*)key;

- (void)removeObjectForKey:(NSString*)key;

- (BOOL)synchronize;

- (void)asynchronize:(void(^)(BOOL isSuccess))asyncblock;

@end
