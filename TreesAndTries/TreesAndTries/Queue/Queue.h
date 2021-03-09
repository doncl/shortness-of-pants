//
//  Queue.h
//  TreesAndTries
//
//  Created by Don Clore on 7/27/20.
//  Copyright © 2020 Don Clore. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Queue<ObjectType> : NSObject

#pragma mark - initializer
- (instancetype _Nullable )init NS_DESIGNATED_INITIALIZER;
#pragma - operations
- (void)enqueue:(nonnull id)value;
- (nullable id)dequeue;

@end

