//
//  NSArray+BinarySearch.m
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "NSArray+BinarySearch.h"

@implementation NSArray (BinarySearch)
- (NSInteger)binarySearchFor:(id)value withComparator:(NSComparator)comparator {
  return [self binarySearchFor:value withComparator:comparator inRange:NSMakeRange(0, self.count)];
}

- (NSInteger)binarySearchFor:(id)value withComparator:(NSComparator)comparator inRange: (NSRange)range {
  
  NSUInteger size = range.length;
  NSUInteger middleIndex = range.location + size / 2;
  id middleValue = self[middleIndex];
  NSComparisonResult comparison = comparator(middleValue, value);
  if (comparison == NSOrderedSame) {
    return middleIndex;
  } else if (comparison == NSOrderedDescending) {
    return [self binarySearchFor:value withComparator:comparator inRange:NSMakeRange(range.location, size / 2)];
  } else {
    return [self binarySearchFor:value withComparator:comparator inRange:NSMakeRange(middleIndex, size / 2)];
  }
}
@end
