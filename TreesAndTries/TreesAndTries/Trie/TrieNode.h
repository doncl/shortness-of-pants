//
//  TrieNode.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>

// Assume nillable.
@interface TrieNode : NSObject
@property (readwrite) NSString *key;
@property (readwrite) TrieNode *parent;
@property (readwrite) BOOL isTerminating;
@property (readwrite) NSMutableDictionary<NSString *, TrieNode *> *children;

- (instancetype)initWithKey:(NSString *)key andParent: (TrieNode *)parent;
@end
