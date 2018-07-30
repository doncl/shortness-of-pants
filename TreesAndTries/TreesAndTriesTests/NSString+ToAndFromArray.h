//
//  NSString+ToAndFromArray.h
//  TreesAndTriesTests
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

// Just a bit of hack to use strings with tries
@interface NSString (ToAndFromArray)
- (NSArray<NSString *> *)toStringArray;
+ (NSString *)fromStringArray:(NSArray<NSString *> *)array;
@end
