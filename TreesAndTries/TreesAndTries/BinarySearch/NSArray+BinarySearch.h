//
//  NSArray+BinarySearch.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSInteger (^ElementComparer)(id, id);

@interface NSArray<ObjectType> (BinarySearch)
- (NSInteger)binarySearchFor:(ObjectType)value withComparer:(ElementComparer)comparer;
@end
