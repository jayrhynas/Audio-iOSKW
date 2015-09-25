//
//  SoundController.h
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AEAudioController;

@interface SoundController : NSObject

@property (strong, nonatomic, readonly) AEAudioController *engine;

- (void)playNote:(int)note withVolume:(float)volume;
- (void)stopNote:(int)note;
- (void)stopAllNotes;

// C versions of above note methods, for fast access
// see comments above playbackTimerCallback in PlaybackController.m
void SoundControllerPlayNote(SoundController* sc, int note, float volume, UInt32 offset);
void SoundControllerStopNote(SoundController* sc, int note, UInt32 offset);
void SoundControllerStopAllNotes(SoundController* sc, UInt32 offset);

@end
