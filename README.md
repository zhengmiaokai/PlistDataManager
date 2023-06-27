# PlistDataManager
### 数据存储-Plist文件
``` objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    MKPlistDataManager *dataStorage = [MKPlistDataManager shareInstance];
    
    [dataStorage setObject:@{@"key": @"value"} forKey:@"data"];
    [dataStorage synchronize];
    
    NSDictionary *data = [dataStorage objectForKey:@"data"];
    NSLog(@"%@", data);
}
```
