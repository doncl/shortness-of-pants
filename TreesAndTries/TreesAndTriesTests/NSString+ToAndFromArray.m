//
//  NSString+ToAndFromArray.m
//  TreesAndTriesTests
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import "NSString+ToAndFromArray.h"

@implementation NSString (ToAndFromArray)
- (NSArray<NSString *> *)toStringArray {
   
  NSMutableArray<NSString *> *array = [[NSMutableArray<NSString *> alloc] init];
  
  [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                           options:(NSStringEnumerationByComposedCharacterSequences)
                        usingBlock:^(NSString * substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                          [array addObject:substring];
                        }];
  
  return array;
}

+ (NSString *)fromStringArray:(NSArray<NSString *> *)array {
  NSUInteger count = array.count;
  NSMutableString *str = [NSMutableString new];
  
  for (int i = 0; i < count; i++) {
    NSString *character = array[i];
    NSAssert(character.length == 1, @"Array must be of single-character strings");
    [str appendString:character];
  }
  
  return str;
}
@end
