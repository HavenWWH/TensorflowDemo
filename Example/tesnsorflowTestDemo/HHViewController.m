//
//  HHViewController.m
//  tesnsorflowTestDemo
//
//  Created by 513433750@qq.com on 01/18/2021.
//  Copyright (c) 2021 513433750@qq.com. All rights reserved.
//

#import "HHViewController.h"
#import "TensorFlowTool.h"
#import "DemoViewController.h"


static NSString *const kQEModelName = @"converted_model";
static NSString *const kQEModelType = @"tflite";

@interface HHViewController ()
@property (nonatomic, strong) TensorFlowTool *tensorFlowTool;

@end

@implementation HHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *otherDemoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherDemoButton.frame = CGRectMake(250, 50, 100, 50);
    [otherDemoButton setTitle:@"demo" forState:UIControlStateNormal];
    [otherDemoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [otherDemoButton addTarget:self action:@selector(otherClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherDemoButton];
    
    
    // 加载模型并初始化
    NSString *path = [[NSBundle mainBundle] pathForResource:kQEModelName ofType:kQEModelType];
    self.tensorFlowTool = [[TensorFlowTool alloc] initWithPath:path];
    if (!self.tensorFlowTool) {
        NSLog(@"加载模型失败");
    }
    
    // 创建二维字节数组
    NSMutableData *inputMubData = [NSMutableData dataWithCapacity:0];
    for (NSString *str in [self tempArr]) {
        float v = [str floatValue];
        [inputMubData appendBytes:&v length:sizeof(float)];
    }
    
    // 模型解析
    NSArray<NSData *> *resultArr = [self.tensorFlowTool run:@[inputMubData]];
    if (!resultArr.count) {
        return;
    }
    
    // 结果处理
    [self resultSetup:resultArr];
}

- (void)resultSetup:(NSArray<NSData *> *)resultArr {
    
    NSInteger totalData = [resultArr.firstObject length] / sizeof(float);
    float output[totalData];
    [resultArr.firstObject getBytes:output length:(sizeof(float) * totalData)];
    CGFloat maxValue = -99999.0;
    int maxIndex = 0;
    for (int i = 0 ; i < totalData; i ++) {
        if (output[i] > maxValue) {
            maxValue = output[i];
            maxIndex = i;
        }
    }
    
    NSString *maxIndexStr = [NSString stringWithFormat:@"%@",@(maxIndex)];
    __block NSString *resultStr = nil;
    [[self wordDict] enumerateKeysAndObjectsUsingBlock:^(NSString  * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:maxIndexStr]) {
            resultStr = obj;
            *stop = YES;
            return;
        }
    }];
    
    NSLog(@"最终识别的字%@",resultStr ? resultStr : @"");
}

- (NSDictionary *)wordDict {
    
    NSString *wordPath = [[NSBundle mainBundle] pathForResource:@"word" ofType:@"json"];
    NSURL *wordUrl=[NSURL fileURLWithPath:wordPath];
    NSData *worsData = [[NSData alloc] initWithContentsOfURL:wordUrl];
    NSDictionary *wordDic = [NSJSONSerialization JSONObjectWithData:worsData options:NSJSONReadingAllowFragments error:nil];
    return wordDic;
}

- (NSArray<NSString *> *)tempArr {
    
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"7799" ofType:@"txt"];
    NSString *fileWords = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    [fileWords stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray *chinesewords = [fileWords componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSMutableArray *arr  = [NSMutableArray arrayWithArray:chinesewords];
    [arr removeLastObject];
    return arr;
}

- (void)otherClick {
    
    [self.navigationController pushViewController:[[DemoViewController alloc] init] animated:true];
}
@end
