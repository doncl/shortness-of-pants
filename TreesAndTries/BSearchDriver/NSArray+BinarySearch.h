//
//  NSArray+BinarySearch.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (BinarySearch)
- (NSInteger)binarySearchFor:(ObjectType) value withComparator:(NSComparator)comparator;
@end
