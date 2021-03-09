//
//  Queue.m
//  TreesAndTries
//
//  Created by Don Clore on 7/27/20.
//  Copyright © 2020 Don Clore. All rights reserved.
//

#import "Queue.h"

@implementation Queue
{
  NSMutableArray *_leftStack;
  NSMutableArray *_rightStack;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _leftStack = [NSMutableArray new];
    _rightStack = [NSMutableArray new];
  }
  
  return self;
}

- (void)enqueue:(id)value {
  [_rightStack addObject:value];
}

- (id)dequeue {
  if (_leftStack.count == 0) {
    _leftStack = [[[_rightStack reverseObjectEnumerator] allObjects] mutableCopy];
    [_rightStack removeAllObjects];
  }
  id lastObject = [_leftStack lastObject];
  if (lastObject) {
    [_leftStack removeLastObject];
  }
  return lastObject;
}

@end
