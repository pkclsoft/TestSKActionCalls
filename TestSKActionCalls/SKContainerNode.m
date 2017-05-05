//
//  SKContainerNode.m
//  TestTextureUpdates
//
//  Created by Peter Easdown on 23/1/17.
//  Copyright © 2017 PKCLsoft. All rights reserved.
//

#import "SKContainerNode.h"

@implementation SKContainerNode


- (void) removeFromParent {
    NSLog(@"SKContainerNode.removeFromParent");

    [self removeAllChildren];

    [super removeFromParent];
}

- (void) removeAllChildren {
    NSLog(@"SKContainerNode.removeAllChildren");

    [self removeChildrenInArray:self.children];

    // In case there is any other behaviour in SKNode
    //
    [super removeAllChildren];
}

- (void) removeChildrenInArray:(NSArray<SKNode *> *)nodes {
    NSLog(@"SKContainerNode.removeChildrenInArray");

    [nodes enumerateObjectsUsingBlock:^(SKNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromParent];
    }];

    // In case there is any other behaviour in SKNode
    //
    [super removeChildrenInArray:nodes];
}
@end
