//
//  NSArray+BinarySearch.m
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "NSArray+BinarySearch.h"

@implementation NSArray (BinarySearch)
- (NSInteger)binarySearchFor:(id)value withComparer:(ElementComparer)comparer {
  return [self binarySearchFor:value withComparer:comparer inRange:NSMakeRange(0, self.count)];
}

- (NSInteger)binarySearchFor:(id)value withComparer:(ElementComparer)comparer inRange: (NSRange)range {
  
  NSUInteger size = range.length;
  NSUInteger middleIndex = range.location + size / 2;
  id middleValue = self[middleIndex];
  NSInteger comparison = comparer(value, middleValue);
  if (comparison == 0) {
    return middleIndex;
  } else if (comparison < 0) {
    return [self binarySearchFor:value withComparer:comparer inRange:NSMakeRange(range.location, size / 2)];
  } else {
    return [self binarySearchFor:value withComparer:comparer inRange:NSMakeRange(middleIndex, size / 2)];
  }
}
@end
