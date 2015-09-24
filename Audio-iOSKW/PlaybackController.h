//
//  PlaybackController.h
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridView.h"

@class SoundController;

@interface PlaybackController : NSObject <GridDelegate>

- (instancetype)initWithSoundController:(SoundController *)soundController;

@end
