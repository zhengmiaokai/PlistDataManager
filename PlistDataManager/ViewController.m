//
//  ViewController.m
//  PlistDataManager
//
//  Created by mikazheng on 2021/8/17.
//

#import "ViewController.h"
#import "MKPlistDataManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    MKPlistDataManager *dataStorage = [MKPlistDataManager shareInstance];
    
    [dataStorage setObject:@{@"key": @"value"} forKey:@"data"];
    [dataStorage synchronize];
    
    NSDictionary *data = [dataStorage objectForKey:@"data"];
    NSLog(@"%@", data);
}


@end
