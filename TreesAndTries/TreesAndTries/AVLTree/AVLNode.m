//
//  AVLNode.m
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "AVLNode.h"


@interface AVLNode ()
// This is rewriting attributes of height to readwrite so we can calculate it in
// recalculateHeight
@property (readwrite)NSUInteger height;
@end

@implementation AVLNode
- (instancetype)init {
  self = [self initWithValue:@1];
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the AVLNode class"
                               userInfo:nil];
  

  return nil;
}

- (instancetype)initWithValue:(id)value{
  self = [super init];
  if (self) {
    self.height = 0;
    self.value = value;
  }
  return self;
}

// From Wenderlich's book on Data Structures and Algorithms in Swift, which itself
// took this algorithm from https://www.objc.io/books/optimizing-collections.  I
// translated it from Swift - didn't look at the original, not that it matters. 
- (NSString *)diagram:(AVLNode *)node top:(NSString *)top root:(NSString *)root bottom:(NSString *)bottom describer: (NodeDescriber)describer {
  if (!node) {
    return [NSString stringWithFormat:@"%@ nil\n", root];
  }
  if (!node.leftChild && !node.rightChild) {
    return [NSString stringWithFormat:@"%@ %@", root, [node.value description]];
  }
  NSString *rightTop = [top stringByAppendingString:@" "];
  NSString *rightRoot = [top stringByAppendingString:@"┌──"];
  NSString *rightBottom = [top stringByAppendingString:@"│ "];
  
  NSString *right = [self diagram:node.rightChild top:rightTop root:rightRoot bottom:rightBottom describer: describer];
  
  NSString *newRoot = [root stringByAppendingString: describer(node)];
  
  NSString *leftTop = [bottom stringByAppendingString:@"│ "];
  NSString *leftRoot = [bottom stringByAppendingString:@"└──"];
  NSString *leftBottom = [bottom stringByAppendingString:@" "];
  
  NSString *left = [self diagram:node.leftChild top:leftTop root:leftRoot bottom:leftBottom describer:describer];
  return [NSString stringWithFormat:@"%@\n%@\n%@", right, newRoot, left];
}

- (NSInteger)leftHeight {
  if (!self.leftChild) {
    return -1;
  }
  return self.leftChild.height;
}

- (NSInteger)rightHeight {
  if (!self.rightChild) {
    return -1;
  }
  return self.rightChild.height;
}

- (NSInteger)balanceFactor {
  return self.leftHeight - self.rightHeight;
}

- (AVLNode *)getMin {
  if (self.leftChild == nil) {
    return self;
  }
  return [self.leftChild getMin];
}

- (void)recalculateHeight {
  self.height = MAX(self.leftHeight, self.rightHeight) + 1;
}

@end
