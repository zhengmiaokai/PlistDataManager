# PlistDataManager
### 数据存储-Plist文件
``` objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [PlistDataStore setObject:@{@"key": @"value"} forKey:@"data"];
    [PlistDataStore synchronize];
    
    NSDictionary* data = [PlistDataStore objectForKey:@"data"];
    NSLog(@"%@", data);
}
```
