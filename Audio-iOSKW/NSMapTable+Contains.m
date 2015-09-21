//
//  NSMapTable+Contains.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "NSMapTable+Contains.h"

@implementation NSMapTable (Contains)

- (BOOL)containsObject:(id)value {
    for (id key in self) {
        id object = [self objectForKey:key];
        if ([object isEqual:value]) return YES;
    }
    return NO;
}

@end
