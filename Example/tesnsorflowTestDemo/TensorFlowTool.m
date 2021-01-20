//
//  TensorFlowTool.m
//  tesnsorflowTestDemo_Example
//
//  Created by Haven on 2021/1/19.
//  Copyright © 2021 513433750@qq.com. All rights reserved.
//


#import "TensorFlowTool.h"

#import <TFLTensorFlowLite.h>


@interface TensorFlowTool ()

@property(nonatomic ,strong) TFLInterpreter *interpreter;
@end

@implementation TensorFlowTool
- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    NSError *error = nil;
    if (self) {
        self.interpreter = [[TFLInterpreter alloc] initWithModelPath:path error:&error];
        if (error) {
            NSLog(@"%@",[NSString stringWithFormat:@"TFLInterpreter init \
                         error message %@",
                         error.localizedDescription]);
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)close {
    self.interpreter = nil;
}

- (BOOL)isReady {
    return (self.interpreter != nil);
}

- (NSArray *)run:(NSArray *)inputDatas {
    
    // 使用过程参照 https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/experimental/objc
//    NSArray<NSNumber *> *shape = @[@2];
//    NSError *error;
//
//    for (int i = 0; i < self.interpreter.inputTensorCount; ++i) {
//      if (![self.interpreter resizeInputTensorAtIndex:i toShape:shape error:&error]) {
//          NSLog(@"resizeInputTensorAtIndex error%@",error.localizedDescription);
//        return nil;
//      }
//    }


    // 初始化 TensorFlow 所有 Tensor
    if (![self allocateTensors:self.interpreter] ||
        ![self setupInputDatas:inputDatas interpreter:self.interpreter] ||
        ![self invokeTensors:self.interpreter]) {
        return nil;
    }
    return [self getOutputDatas:self.interpreter];
}

// 分配内存
- (BOOL)allocateTensors:(TFLInterpreter *)interpreter {
    NSError *error = nil;
    if (![interpreter allocateTensorsWithError:&error]) {
        
        NSLog(@"%@",[NSString stringWithFormat:@"allocateTensorsWithError %@",error.localizedDescription]);
        return NO;
    }
    return YES;
}

- (BOOL)setupInputDatas:(NSArray *)inputDatas interpreter:(TFLInterpreter *)interpreter {
    
    NSError *error = nil;
    if (inputDatas.count < 1) {
        
        NSLog(@"%@",[NSString stringWithFormat:@"inputData  is \
                     empty  %@",
                     inputDatas]);
        return NO;
    }
    for (int i = 0; i < inputDatas.count; i++) {
        NSData *inputData = inputDatas[i];
        TFLTensor *inputTensor = [interpreter inputTensorAtIndex:i error:&error];
        if (!inputTensor ||
            error) {
            NSLog(@"%@",[NSString stringWithFormat:@"inputTensor get \
                         error message  %@",
                         error.localizedDescription]);
            return NO;
        }
        [inputTensor copyData:inputData error:&error];
        if (error) {
            NSLog(@"%@",[NSString stringWithFormat:@"inputTensor copyData \
                         error message  %@",
                         error.localizedDescription]);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)setupInputData:(NSData *)inputData interpreter:(TFLInterpreter *)interpreter {
    NSError *error = nil;
    TFLTensor *inputTensor = [interpreter inputTensorAtIndex:0 error:&error];
    if (!inputTensor ||
        error) {
        NSLog(@"%@",[NSString stringWithFormat:@"inputTensor get \
                     error message  %@",
                     error.localizedDescription]);
        return NO;
    }
    [inputTensor copyData:inputData error:&error];
    if (error) {
        NSLog(@"%@",[NSString stringWithFormat:@"inputTensor copyData \
                     error message  %@",
                     error.localizedDescription]);
        return NO;
    }
    return YES;
}

- (BOOL)invokeTensors:(TFLInterpreter *)interpreter {
    NSError *error = nil;
    if (![interpreter invokeWithError:&error]) {
        NSLog(@"%@",[NSString stringWithFormat:@"allocateTensorsWithError %@",
                     error.localizedDescription]);
        return NO;
    }
    return YES;
}

- (NSArray *)getOutputDatas:(TFLInterpreter *)interpreter {
    NSError *error = nil;
    NSData *outData = nil;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < interpreter.outputTensorCount; i++) {
        TFLTensor *outputTensor = [interpreter outputTensorAtIndex:i error:&error];
        if (!outputTensor ||
            error) {
            NSLog(@"%@",[NSString stringWithFormat:@"get outputTensor \
                         error message  %@",
                         error.localizedDescription]);
            return nil;
        }
        
        outData = [outputTensor dataWithError:&error];
        if (error) {
            NSLog(@"%@",[NSString stringWithFormat:@"get outData error message  %@",error.localizedDescription]);
            return nil;
        }
        [array addObject:outData];
    }
    return array;

}

- (NSData *)getOutputData:(TFLInterpreter *)interpreter {
    NSError *error = nil;
    NSData *outData = nil;
    TFLTensor *outputTensor = [interpreter outputTensorAtIndex:0 error:&error];
    if (!outputTensor ||
        error) {
        NSLog(@"%@",[NSString stringWithFormat:@"get outputTensor \
                     error message  %@",
                     error.localizedDescription]);
        return outData;
    }
    
    outData = [outputTensor dataWithError:&error];
    if (error) {
        NSLog(@"%@",[NSString stringWithFormat:@"get outData error message  %@",error.localizedDescription]);
        return nil;
    }
    return outData;
}
@end
