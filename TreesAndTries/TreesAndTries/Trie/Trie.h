//
//  Trie.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trie : NSObject

- (instancetype)init;
- (void)insert:(NSString *)collection;
- (BOOL)contains:(NSString *)collection;
- (NSArray *)collections:(NSString *)prefix;
@end
