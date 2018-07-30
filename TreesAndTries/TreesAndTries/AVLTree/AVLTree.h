//
//  AVLTree.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVLNode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger (^ComparisonBlock)(id, id);

#pragma mark - initializer
@interface AVLTree<ObjectType> : NSObject
- (instancetype)initWithComparer:(ComparisonBlock)comparer andDescriber:(NodeDescriber) describer NS_DESIGNATED_INITIALIZER;

#pragma mark - operations
- (void)insert:(id)value;
- (void)remove:(id)value;
- (NSString *)diagram;
@end

NS_ASSUME_NONNULL_END
