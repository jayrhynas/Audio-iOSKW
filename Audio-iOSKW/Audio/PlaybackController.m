//
//  PlaybackController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "PlaybackController.h"

#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

#import "SoundController.h"
#import "Constants.h"

@interface PlaybackController() <AEAudioTimingReceiver> {
    BOOL _grid[GridRows][GridCols];
    
    Float64 _samplesPerBeat;
    Float64 _playingSamplesPerBeat;
    Float64 _samplePos;
    
    Float64 _sampleRate;
    
    BOOL _firstBeat;
}

@property (weak, nonatomic) SoundController *soundController;

@property (nonatomic) BOOL playing;
@property (nonatomic) int  bpm;

@end

@implementation PlaybackController

#pragma mark - Properties

- (void)setBpm:(int)bpm
{
    if (bpm == _bpm) return;
    _bpm = bpm;
    
    // pre-compute samples per beat so we don't have to during playback
    _samplesPerBeat = _sampleRate / ((Float64)_bpm / 60.0) / 4.0;
}

- (void)setPlaying:(BOOL)playing {
    if (playing == _playing) return;
    
    _playing = playing;
    
    // reset first beat whenever playback status changes
    _firstBeat = YES;
    _samplePos = 0;
    
    [self.soundController stopAllNotes];
}

- (instancetype)initWithSoundController:(SoundController *)soundController
{
    if (!(self = [super init])) return nil;

    self.soundController = soundController;
    [soundController.engine addTimingReceiver:self];
    
    memset(_grid, 0, GridRows * GridCols * sizeof(BOOL));
    _sampleRate = soundController.engine.audioDescription.mSampleRate;
    _samplePos = 0;
    
    self.bpm = DefaultBPM;
    _playingSamplesPerBeat = _samplesPerBeat;

    return self;
}

// returns a reference to our C callback - required by AEAudioTimingReceiver protocol
- (AEAudioControllerTimingCallback)timingReceiverCallback {
    return &playbackTimerCallback;
}


// This callback is called on the audio rendering thread every time a buffer of audio
// is requested. It has to be very fast, otherwise you will hear audio glitches/stuttering.
// This means you can't take any locks, no dispatch_sync (or dispatch at all), and even try
// to avoid Objective C (as the objc runtime can take locks).
// By delcaring this callback within PlaybackController's @implementation...@end block, we
// can directly access its ivars using the -> operator, avoiding objc. Similarly, we use
// C versions of SoundControllerPlayNote() etc to avoid objc method dispatch.

void playbackTimerCallback(__unsafe_unretained id                 receiver,
                           __unsafe_unretained AEAudioController *audioController,
                           const AudioTimeStamp                  *time,
                           UInt32                                 samples,
                           AEAudioTimingContext                   context)
{
    // only care about output
    if (context != AEAudioTimingContextOutput) return;
    
    // receiver is the object that regisitered itself as the timing receiver
    // (in this case, our PlaybackController)
    PlaybackController *SELF = (PlaybackController *)receiver;
    SoundController    *sc   = SELF->_soundController;

    if (SELF->_playing) {
        // if our samples per beat has changed (i.e. bpm changed),
        // we need to recalculate our sample position
        if (SELF->_playingSamplesPerBeat != SELF->_samplesPerBeat) {
            Float64 beat = SELF->_samplePos / SELF->_playingSamplesPerBeat;
            SELF->_samplePos = beat * SELF->_samplesPerBeat;
            SELF->_playingSamplesPerBeat = SELF->_samplesPerBeat;
        }
        
        // save the values before incrementing
        int prevPos = SELF->_samplePos;
        int prevBeat = prevPos / SELF->_samplesPerBeat;

        // increment our position by the number of samples
        SELF->_samplePos += samples;
        
        // figure out what column we're on now (note: implicit truncation)
        int curBeat = SELF->_samplePos / SELF->_samplesPerBeat;
        
        // figure out how far into the audio buffer our beat lies
        Float64 offset = 0;
        if (!SELF->_firstBeat) {
            offset = curBeat * SELF->_samplesPerBeat - prevPos;
        }
        
        // if we've gone past the end of the grid, loop around to the beginning
        if (curBeat >= GridCols) {
            // how far into the next beat are we?
            Float64 sampleOffset = SELF->_samplePos - curBeat * SELF->_samplesPerBeat;
            
            // wrap beat
            curBeat = curBeat % GridCols;
            SELF->_firstBeat = YES;
            
            // update position, including offset into current beat
            SELF->_samplePos = curBeat * SELF->_samplesPerBeat + sampleOffset;
        }
        
        // if our (integral) beat has changed, or if this is the first beat, start & stop notes
        if (curBeat != prevBeat || SELF->_firstBeat) {
            for (int r = 0; r < GridRows; r++) {
                // any cell that was on in the previous column needs to be stopped
                if (SELF->_grid[r][prevBeat]) {
                    SoundControllerStopNote(sc, r + BaseNote, offset);
                }
                
                // any cell that is on in the new column needs to be started
                if (SELF->_grid[r][curBeat]) {
                    SoundControllerPlayNote(sc, r + BaseNote, 1.0, offset);
                }
            }
        }
        
        // clear first beat flag
        SELF->_firstBeat = NO;
    }
}


#pragma mark - GridDelegate

- (void)cellToggled:(Cell)cell toState:(BOOL)state {
    _grid[cell.row][cell.col] = state;
}

- (void)bpmChanged:(int)bpm {
    self.bpm = bpm;
}

- (void)cellEnter:(Cell)cell {}
- (void)cellLeave:(Cell)cell {}

- (void)playbackToggled:(BOOL)playing {
    self.playing = playing;
}

@end
