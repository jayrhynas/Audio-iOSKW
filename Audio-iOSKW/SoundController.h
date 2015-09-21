//
//  SoundController.h
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundController : NSObject

- (void)playNote:(int)note withVolume:(float)volume;
- (void)stopNote:(int)note;

@end
