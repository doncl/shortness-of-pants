//
//  main.m
//  BSearchDriver
//
//  Created by Don Clore on 7/26/20.
//  Copyright © 2020 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+BinarySearch.h"


int main(int argc, const char * argv[]) {
  @autoreleasepool {
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
    
    NSInteger index = [sortedItems binarySearchFor:@"bananas" withComparator:^NSComparisonResult(id lhs, id rhs) {
      return [lhs compare: rhs options: NSCaseInsensitiveSearch];
    }];
    
    NSString *bananas = sortedItems[index];
    NSLog(@"Index = %lu, string found = %@", index, bananas);
    
  }
    
  return 0;
}
