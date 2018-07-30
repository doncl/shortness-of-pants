//
//  AVLNode.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVLNode;

typedef NSString * (^NodeDescriber)(AVLNode *);

NS_ASSUME_NONNULL_BEGIN

@interface AVLNode<ObjectType> : NSObject
@property (readwrite)ObjectType value;


@property (readonly)NSUInteger height;



@property (nullable) AVLNode<ObjectType> * leftChild;
@property (nullable) AVLNode<ObjectType> * rightChild;

- (instancetype)initWithValue:(id)ObjectType NS_DESIGNATED_INITIALIZER;

- (NSInteger)balanceFactor;
- (NSInteger)leftHeight;
- (NSInteger)rightHeight;

- (void)recalculateHeight;
- (AVLNode<ObjectType> *)getMin;

- (NSString *)diagram:(nullable AVLNode *)node top:(NSString *)top root:(NSString *)root bottom:(NSString *)bottom describer:(NodeDescriber)describer;
@end

NS_ASSUME_NONNULL_END
