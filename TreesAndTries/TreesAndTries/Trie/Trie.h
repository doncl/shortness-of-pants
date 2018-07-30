//
//  Trie.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trie<ObjectType> : NSObject

- (instancetype)init;
- (void)insert:(NSArray<ObjectType> *)collection;
- (BOOL)contains:(NSArray<ObjectType> *)collection;
- (NSArray *)collections:(NSArray<ObjectType> *)prefix;
@end
