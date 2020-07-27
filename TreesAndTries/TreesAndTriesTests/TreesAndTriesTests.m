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
  NSString *cute = @"cute";
  [t insert:cute];

  XCTAssert([t contains: cute]);
}

- (void)testTrieAutoSuggest {
  Trie *t = [[Trie alloc] init];
  [t insert:@"car"];
  [t insert:@"card"];
  [t insert:@"care"];
  [t insert:@"cared"];
  [t insert:@"cars"];
  [t insert:@"carbs"];
  [t insert:@"carapace"];
  [t insert:@"cargo"];
  
  NSArray<NSString *> *results = [t collections:@"car"];
  XCTAssert(results.count == 8);
  for (NSString *result in results) {
    NSLog(@"%@", result);
  }

  results = [t collections:@"care"];
  XCTAssert(results.count == 2);
  for (NSString *result in results) {
    NSLog(@"%@", result);
  }
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

  NSUInteger binarySearch31 = [array binarySearchFor:@31 withComparator:^NSComparisonResult(id lhs, id rhs) {
    NSNumber *num0 = (NSNumber *)lhs;
    NSNumber *num1 = (NSNumber *)rhs;
    return num0.intValue - num1.intValue;
  }];

  NSLog(@"%ld", (unsigned long)binarySearch31);

  XCTAssertEqual(search31, binarySearch31);
}

- (void) testMoreBinSearch {
  NSArray<NSString *> * items = @[@"mangoes", @"apples", @"cherries", @"oranges",
                                   @"grapes", @"bananas", @"periwinkles", @"pears"];

   NSArray<NSString *> * sorted = [items sortedArrayUsingComparator: ^NSComparisonResult(id lhs, id rhs) {
     return [lhs compare: rhs options:NSCaseInsensitiveSearch];
   }];

   NSLog(@"Result from sorting invariant array = %@", sorted);

   NSMutableArray<NSString *> *mutableItems = [[NSMutableArray<NSString *> alloc] initWithArray:items];

   [mutableItems sortUsingComparator:^NSComparisonResult(id lhs, id rhs) {
     return [lhs compare: rhs options:NSCaseInsensitiveSearch];
   }];

   NSLog(@"Sorting mutable items in place using comparator = %@", mutableItems);

   NSArray<NSString *> *sortedItems = [items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

   NSLog(@"Result of sorting invariant items with selector = %@", sortedItems);

   for (NSInteger i = 0; i < sortedItems.count; i++) {
     NSString *itemToFind = sortedItems[i];
     NSInteger index = [sortedItems binarySearchFor:itemToFind withComparator:^NSComparisonResult(id lhs, id rhs) {
       return [lhs compare:rhs options:NSCaseInsensitiveSearch];
     }];
     NSString *itemFound = sortedItems[index];
     NSLog(@"Index = %lu, string found = %@", index, itemFound);
   }

   NSString *notExist = @"Does not Exist";
   NSInteger notFoundIndex = [sortedItems binarySearchFor:notExist withComparator:^NSComparisonResult(id lhs, id rhs) {
     return [lhs compare: rhs options: NSCaseInsensitiveSearch];
   }];

   NSLog(@"findResult for \"%@\" is found = %@", notExist, notFoundIndex == NSNotFound ? @"NO" : @"YES" );
}



@end
