//
//  TrieNode.m
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "TrieNode.h"

@implementation TrieNode
- (instancetype)initWithKey:(NSString *)key andParent:(TrieNode *)parent {
  self = [super init];
  if (self) {
    self.key = key;
    self.parent = parent;
    self.children = [NSMutableDictionary<NSString *, TrieNode *> new];
  }
  return self;
}
@end
