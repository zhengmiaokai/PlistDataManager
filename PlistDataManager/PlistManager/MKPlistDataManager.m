//
//  MKPlistDataManager.m
//  SocialElectricity
//
//  Created by zhengmiaokai on 15/9/3.
//  Copyright (c) 2015年 JD.com. All rights reserved.
//

#import "MKPlistDataManager.h"
#import <MKUtils/NSFileManager+Addition.h>

@interface MKPlistDataManager()

@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, strong) NSMutableDictionary* plistData;
@property (nonatomic, strong) NSRecursiveLock* lock;
@property (nonatomic, strong) dispatch_queue_t serial_queue;

@end

@implementation MKPlistDataManager

+ (instancetype)shareInstance {
    static MKPlistDataManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] initWithFileName:@"app_db.plist"];
    });
    return manager;
}

- (instancetype)initWithFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        self.filePath = [self pathToSave:fileName];
        self.lock = [[NSRecursiveLock alloc] init];
        self.serial_queue = dispatch_queue_create("plist_manager_queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return self;
}

- (NSString*)pathToSave:(NSString *)fileName {
    NSString* folderPath = [NSFileManager forderPathWithFolderName:@"app_plist" directoriesPath:DocumentPath()];
    NSString* filePath = [NSFileManager pathWithFileName:fileName foldPath:folderPath];
    
    return filePath;
}

- (NSMutableDictionary *)plistData {
    if (_plistData == nil) {
        NSDictionary* dataDic = [[NSDictionary alloc]
                                 initWithContentsOfFile:_filePath];
        _plistData = [NSMutableDictionary
                      dictionaryWithDictionary:dataDic];
    }
    return _plistData;
}

- (id)objectForKey:(NSString*)key {
    [_lock lock];
    id object = [self.plistData objectForKey:key];
    [_lock unlock];
    return object;
}

- (void)setObject:(id)object forKey:(NSString*)key {
    if (object == nil) {
        NSLog(@"PlistManager object isNULL");
        return;
    }
    [_lock lock];
    [self.plistData setObject:object forKey:key];
    [_lock unlock];
}

- (void)removeObjectForKey:(NSString*)key {
    [_lock lock];
    [self.plistData removeObjectForKey:key];
    [_lock unlock];
}

- (void)asynchronize:(void(^)(BOOL isSuccess))asyncblock {
    dispatch_async(_serial_queue, ^{
        BOOL isSuccess = [self synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (asyncblock) {
                asyncblock(isSuccess);
            }
        });
    });
}

- (BOOL)synchronize {
    NSDictionary* plistData = nil;
    [_lock lock];
    plistData = [self.plistData copy];
    self.plistData = nil;
    [_lock unlock];
    
    BOOL success = [plistData writeToFile:_filePath atomically:YES];
    
    return success;
}
@end
