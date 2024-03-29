//
//  MKPlistDataManager.m
//  SocialElectricity
//
//  Created by zhengmiaokai on 15/9/3.
//  Copyright (c) 2015年 JD.com. All rights reserved.
//

#import "MKPlistDataManager.h"

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@interface MKPlistDataManager()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSMutableDictionary *plistData;
@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

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
        self.filePath = [self createFilePath:fileName];
        self.lock = dispatch_semaphore_create(1);
        self.serialQueue = dispatch_queue_create("com.MKPlistManager.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSString*)createFilePath:(NSString *)fileName {
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folderPath = [self _folderPathWithFolderName:@"app_plist" directoriesPath:documentPath];
    NSString *filePath = [self _pathWithFileName:fileName foldPath:folderPath];
    
    return filePath;
}

- (NSMutableDictionary *)plistData {
    if (_plistData == nil) {
        NSDictionary *datas = [[NSDictionary alloc] initWithContentsOfFile:_filePath];
        _plistData = [NSMutableDictionary dictionaryWithDictionary:datas];
    }
    return _plistData;
}

- (id)objectForKey:(NSString *)key {
    LOCK(id object = [self.plistData objectForKey:key]);
    return object;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    if (object == nil) {
        NSLog(@"PlistManager object isNULL");
        return;
    }
    LOCK([self.plistData setObject:object forKey:key]);
}

- (void)removeObjectForKey:(NSString *)key {
    LOCK([self.plistData removeObjectForKey:key]);
}

- (void)removeAllObjects {
    LOCK([self.plistData removeAllObjects]);
}

- (NSDictionary *)keyValues {
    LOCK(NSDictionary *plistData = [self.plistData copy]);
    return plistData;
}

- (void)asynchronize:(void(^)(BOOL success))completionHandler {
    dispatch_async(_serialQueue, ^{
        BOOL success = [self synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(success);
            }
        });
    });
}

- (BOOL)synchronize {
    LOCK(NSDictionary *plistData = [self.plistData copy];
         self.plistData = nil);
    
    BOOL success = [plistData writeToFile:_filePath atomically:YES];
    return success;
}

#pragma mark - Private -
- (NSString *)_folderPathWithFolderName:(NSString*)folderName directoriesPath:(NSString *)directoriesPath {
    NSString* folderPath = [directoriesPath stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Create Audio Directory Failed.");
        }
    }
    return folderPath;
}

- (NSString*)_pathWithFileName:(NSString*)fileName foldPath:(NSString*)folderPath {
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
