//
//  TreesAndTriesTests.m
//  TreesAndTriesTests
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AVLTree.h"
#import "Trie.h"
#import "NSString+ToAndFromArray.h"
#import "NSArray+BinarySearch.h"

@interface TreesAndTriesTests : XCTestCase

@end

@implementation TreesAndTriesTests

- (AVLTree<NSNumber *> *)getTree {
  AVLTree<NSNumber *> *t = [[AVLTree<NSNumber *> alloc] initWithComparer:^NSInteger (id n0, id n1) {
    NSNumber *num0 = (NSNumber *)n0;
    NSNumber *num1 = (NSNumber *)n1;
    return num0.intValue - num1.intValue;
  } andDescriber:^NSString * (AVLNode *node)  {
    NSNumber *num = (NSNumber *)node.value;
    return [NSString stringWithFormat:@"%d", num.intValue];
  }];
  return t;
}

- (void)printTree:(AVLTree *)t {
  NSString *diagram = [t diagram];
  NSLog(@"%@", diagram);
}

- (void)testExerciseAvlTreeInsertions {
  AVLTree<NSNumber *> *t = [self getTree];

  for (int i = 0; i < 15; i++) {
    [t insert:[NSNumber numberWithInt:i]];
  }

  [self printTree:t];
}

- (void)testExerciseAvlTreeDeletions {
  AVLTree<NSNumber *> *t = [self getTree];
  [t insert:[NSNumber numberWithInt: 15]];
  [t insert:[NSNumber numberWithInt: 10]];
  [t insert:[NSNumber numberWithInt: 16]];
  [t insert:[NSNumber numberWithInt: 18]];

  [self printTree:t];
  [t remove:[NSNumber numberWithInt:10]];

  [self printTree:t];
}

- (void)testTrieInsertAndContains {
  Trie *t = [[Trie alloc] init];
  NSArray<NSString *> *cuteArray = [@"cute" toStringArray];
  [t insert:cuteArray];

  XCTAssert([t contains: cuteArray]);
}

- (void)insertStringValue:(Trie *)t stringValue: (NSString *)stringValue {
  NSArray<NSString *> *strArray = [stringValue toStringArray];
  [t insert:strArray];
}

- (void)testTrieAutoSuggest {
  Trie *t = [[Trie alloc] init];
  [self insertStringValue:t stringValue:@"car"];
  [self insertStringValue:t stringValue:@"card"];
  [self insertStringValue:t stringValue:@"care"];
  [self insertStringValue:t stringValue:@"cared"];
  [self insertStringValue:t stringValue:@"cars"];
  [self insertStringValue:t stringValue:@"carbs"];
  [self insertStringValue:t stringValue:@"carapace"];
  [self insertStringValue:t stringValue:@"cargo"];
  
  NSArray<NSString *> *results = [self prefixedResults:t startingWith:@"car"];
  XCTAssert(results.count == 8);
  for (NSString *result in results) {
    NSLog(@"%@", result);
  }

  results = [self prefixedResults:t startingWith:@"care"];
  XCTAssert(results.count == 2);
  for (NSString *result in results) {
    NSLog(@"%@", result);
  }
}

- (NSArray<NSString *> *)prefixedResults:(Trie *) t startingWith: (NSString *)prefix {
  NSLog(@"Collections starting with \"%@\"", prefix);
  NSArray<NSString *> *array = [prefix toStringArray];
  NSArray<NSArray<NSString *> *> *prefixed = [t collections:array];
  NSMutableArray<NSString *> *results = [[NSMutableArray<NSString *> alloc] initWithCapacity:prefixed.count];
  for (NSArray<NSString *> *stringArray in prefixed) {
    NSString *result = [NSString fromStringArray:stringArray];
    [results addObject:result];
  }
  return results;
}

- (void)testBinarySearch {
  NSMutableArray<NSNumber *> *array = [NSMutableArray<NSNumber *> new];
  [array addObject:@1];
  [array addObject:@5];
  [array addObject:@15];
  [array addObject:@17];
  [array addObject:@19];
  [array addObject:@22];
  [array addObject:@24];
  [array addObject:@31];
  [array addObject:@105];
  [array addObject:@150];
  
  NSUInteger search31 = [array indexOfObject:@31];
  NSLog(@"%ld", (unsigned long)search31);
  
  NSUInteger binarySearch31 = [array binarySearchFor:@31 withComparator:^NSInteger(id n0, id n1) {
    NSNumber *num0 = (NSNumber *)n0;
    NSNumber *num1 = (NSNumber *)n1;
    return num0.intValue - num1.intValue;
  }];
  
  NSLog(@"%ld", (unsigned long)binarySearch31);
  
  XCTAssertEqual(search31, binarySearch31);
}


@end
