//
//  AVLTree.m
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "AVLTree.h"
#import "AVLNode.h"

@interface AVLTree ()
@property AVLNode *root;
@property ComparisonBlock comparer;
@property NodeDescriber describer;
@end

@implementation AVLTree
- (instancetype)init {
  self = [self initWithComparer:^NSInteger (id obj1, id obj2) {
    return 0;
  } andDescriber:^NSString *(AVLNode *node) {
    return @"";
  }];
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the AVLTree class"
                               userInfo:nil];
  
  return nil;
}

- (instancetype)initWithComparer:(ComparisonBlock)comparer andDescriber:(NodeDescriber)describer {
  self = [super init];
  if (self) {
    self.root = nil;
    self.comparer = comparer;
    self.describer = describer;
  }
  return self;
}

- (NSString *)diagram {
  NSString * dia = [self.root diagram:self.root top:@" " root:@" " bottom:@" " describer:self.describer];
  return [@"\n" stringByAppendingString:dia];
}

#pragma mark - insertions
- (void)insert:(id)value {
  self.root = [self insert:value after:self.root];
}

- (AVLNode *)insert:(id)value after: (AVLNode *)node {
  if (node == nil) {
    return [[AVLNode alloc]initWithValue:value];
  }
  
  NSInteger comparison = self.comparer(value, node.value);
  if (comparison < 0) {
    node.leftChild = [self insert:value after:node.leftChild];
  } else {
    node.rightChild = [self insert:value after:node.rightChild];
  }
  AVLNode *bal = [self balanced:node];
  [bal recalculateHeight];
  return bal;
}

#pragma mark - removal
- (void)remove:(id)value {
    self.root = [self remove:value after:self.root];
}

- (AVLNode *)remove:(id)value after: (AVLNode *)node {
  if (!node) {
    return nil;
  }
  
  NSInteger comparison = self.comparer(value, node.value);
  if (comparison == 0) { // They're equal
    if (!node.leftChild && !node.rightChild) {
      return nil;
    }
    if (!node.leftChild) {
      return node.rightChild;
    }
    if (!node.rightChild) {
      return node.leftChild;
    }
    // Both are non-null.
    node.value = [node.rightChild getMin].value;
    node.rightChild = [self remove:node.value after:node.rightChild];
  } else if (comparison < 0) {
    node.leftChild = [self remove:value after: node.leftChild];
  } else {
    node.rightChild = [self remove:value after:node.rightChild];
  }
  AVLNode *bal = [self balanced:node];
  [bal recalculateHeight];
  return bal;
}

#pragma mark - balancing_act
- (AVLNode *)leftRotate:(AVLNode *)node {
  NSAssert(node.rightChild, @"Right child nil on leftRotate");
  AVLNode *pivot = node.rightChild;
  node.rightChild = pivot.leftChild;
  pivot.leftChild = node;
  
  [node recalculateHeight];
  [pivot recalculateHeight];
  
  return pivot;
}

- (AVLNode *)rightLeftRotate:(AVLNode *)node {
  AVLNode *rightChild = node.rightChild;
  if (!rightChild) {
    return node;
  }
  node.rightChild = [self rightRotate:rightChild];
  return [self leftRotate:node];
}

- (AVLNode *)rightRotate:(AVLNode *)node {
  NSAssert(node.leftChild, @"left child nil on rightRotate");
  
  AVLNode *pivot = node.leftChild;
  node.leftChild = pivot.rightChild;
  pivot.rightChild = node;
  
  [node recalculateHeight];
  [pivot recalculateHeight];
  
  return pivot;
}

- (AVLNode *)leftRightRotate:(AVLNode *)node {
  AVLNode *leftChild = node.leftChild;
  if (!leftChild) {
    return node;
  }
  node.leftChild = [self leftRotate:leftChild];
  return [self rightRotate:node];
}

- (AVLNode *)balanced:(AVLNode *)node {
  switch (node.balanceFactor) {
    case 2:
      if (node.leftChild && node.leftChild.balanceFactor == -1) {
        return [self leftRightRotate:node];
      } else {
        return [self rightRotate:node];
      }
      break;
    case -2:
      if (node.rightChild && node.rightChild.balanceFactor == 1) {
        return [self rightLeftRotate:node];
      } else {
        return [self leftRotate:node];
      }
      break;
    default:
      return node;
  }
}

@end









