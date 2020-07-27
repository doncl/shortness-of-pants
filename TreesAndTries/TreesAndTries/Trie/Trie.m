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

#pragma mark - initialization

- (instancetype)init {
  self = [super init];
  if (self) {
    self.root = [[TrieNode alloc] initWithKey:nil andParent:nil];
  }
  return self;
}

#pragma mark - insert and contains
- (void)insert:(NSString *)collection {
  TrieNode *current = self.root;
  
  for (NSInteger i = 0; i < collection.length; i++) {
    unichar c = [collection characterAtIndex:i];
    NSString *element = [NSString stringWithFormat:@"%C", c];
    TrieNode *child = current.children[element];
    if (!child) {
      current.children[element] = [[TrieNode alloc] initWithKey:element andParent:current];
      child = current.children[element];
    }
    current = child;
  }
  current.isTerminating = YES;
}

- (BOOL)contains:(NSString *)collection {
  TrieNode *current = self.root;
  
  for (NSInteger i = 0; i < collection.length; i++) {
    unichar c = [collection characterAtIndex:i];
    NSString *element = [NSString stringWithFormat:@"%C", c];

    TrieNode *child = current.children[element];
    if (!child) {
      return NO;
    }
    current = child;
  }
  return current.isTerminating;
}

#pragma mark - collections from prefix (autocomplete)
- (NSArray<NSString *> *)collections:(NSString *)prefix {
  TrieNode *current = self.root;
  
  for (NSInteger i = 0; i < prefix.length; i++) {
    unichar c = [prefix characterAtIndex:i];
    NSString *element = [NSString stringWithFormat:@"%C", c];

    TrieNode *child = current.children[element];
    if (!child) {
      return [NSArray new];  // empty
    }
    current = child;
  }
  
  return [self collections:prefix after:current];
}

- (NSArray<NSString *> *)collections:(NSString *)prefix after: (TrieNode *)node {
  NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:intialCapacity];

  if (node.isTerminating) {
    [values addObject:prefix];
  }
  
  for (TrieNode *child in node.children.allValues) {
    NSMutableString *newPrefix = [prefix mutableCopy];
    [newPrefix appendString:child.key];
    NSArray *intermediateResults = [self collections:newPrefix after:child];
    [values addObjectsFromArray:intermediateResults];
  }
  
  return values;
}

@end
