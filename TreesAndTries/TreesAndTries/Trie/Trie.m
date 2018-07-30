//
//  Trie.m
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "Trie.h"
#import "TrieNode.h"

const int intialCapacity = 50;

@interface Trie()
@property (readwrite) TrieNode *root;
@end

@implementation Trie

- (instancetype)init {
  self = [super init];
  if (self) {
    self.root = [[TrieNode alloc] initWithKey:nil andParent:nil];
  }
  return self;
}

- (void)insert:(NSArray *)collection {
  TrieNode *current = self.root;
  
  for (id element in collection) {
    TrieNode *child = current.children[element];
    if (!child) {
      current.children[element] = [[TrieNode alloc] initWithKey:element andParent:current];
      child = current.children[element];
    }
    current = child;
  }
  current.isTerminating = YES;
}

- (BOOL)contains:(NSArray *)collection {
  TrieNode *current = self.root;
  
  for (id element in collection) {
    TrieNode *child = current.children[element];
    if (!child) {
      return NO;
    }
    current = child;
  }
  return current.isTerminating;
}

- (NSArray<NSArray *> *)collections:(NSArray *)prefix {
  TrieNode *current = self.root;
  
  for (id element in prefix) {
    TrieNode *child = current.children[element];
    if (!child) {
      return [NSArray new];  // empty
    }
    current = child;
  }
  
  return [self collections:prefix after:current];
}

- (NSArray<NSArray *> *)collections:(NSArray *)prefix after: (TrieNode *)node {
  NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:intialCapacity];

  if (node.isTerminating) {
    [values addObject:prefix];
  }
  
  for (TrieNode *child in node.children.allValues) {
    NSMutableArray *newPrefix = [prefix mutableCopy];
    [newPrefix addObject:child.key];
    NSArray *intermediateResults = [self collections:newPrefix after:child];
    [values addObjectsFromArray:intermediateResults];
  }
  
  return values;
}

@end
