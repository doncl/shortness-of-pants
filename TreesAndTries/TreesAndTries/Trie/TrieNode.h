//
//  TrieNode.h
//  TreesAndTries
//
//  Created by Don Clore on 7/29/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>
// Assume nillable.
@interface TrieNode<ObjectType> : NSObject
@property (readwrite) ObjectType key;
@property (readwrite) TrieNode<ObjectType> *parent;
@property (readwrite) BOOL isTerminating;
@property (readwrite) NSMutableDictionary<ObjectType, TrieNode *> *children;

- (instancetype)initWithKey:(ObjectType)key andParent: (TrieNode *)parent;
@end
