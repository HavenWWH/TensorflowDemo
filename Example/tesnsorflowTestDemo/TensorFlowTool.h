//
//  TensorFlowTool.h
//  tesnsorflowTestDemo_Example
//
//  Created by Haven on 2021/1/19.
//  Copyright © 2021 513433750@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TensorFlowTool : NSObject

- (instancetype)initWithPath:(NSString *)path;

- (NSArray *)run:(NSArray *)inputDatas;
@end

NS_ASSUME_NONNULL_END
