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
    
    _samplesPerBeat = _sampleRate / ((Float64)_bpm / 60.0) / 4.0;
}

- (void)setPlaying:(BOOL)playing {
    if (playing == _playing) return;
    
    _playing = playing;
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
    
    self.bpm = 128;
    _playingSamplesPerBeat = _samplesPerBeat;

    return self;
}

- (AEAudioControllerTimingCallback)timingReceiverCallback {
    return &playbackTimerCallback;
}

void playbackTimerCallback(__unsafe_unretained id                 receiver,
                           __unsafe_unretained AEAudioController *audioController,
                           const AudioTimeStamp                  *time,
                           UInt32                                 samples,
                           AEAudioTimingContext                   context)
{
    if (context != AEAudioTimingContextOutput) return;
    
    PlaybackController *SELF = (PlaybackController *)receiver;
    SoundController    *sc   = SELF->_soundController;

    if (SELF->_playing) {
        if (SELF->_playingSamplesPerBeat != SELF->_samplesPerBeat) {
            Float64 beat = SELF->_samplePos / SELF->_playingSamplesPerBeat;
            SELF->_samplePos = beat * SELF->_samplesPerBeat;
            SELF->_playingSamplesPerBeat = SELF->_samplesPerBeat;
        }
        
        int prevPos = SELF->_samplePos;
        int prevBeat = prevPos / SELF->_samplesPerBeat;

        SELF->_samplePos += samples;
        
        int curBeat = SELF->_samplePos / SELF->_samplesPerBeat;
        
        Float64 offset = 0;
        if (!SELF->_firstBeat) {
            offset = curBeat * SELF->_samplesPerBeat - prevPos;
        }
        
        if (curBeat >= GridCols) {
            Float64 sampleOffset = SELF->_samplePos - curBeat * SELF->_samplesPerBeat;
            
            curBeat = curBeat % GridCols;
            SELF->_firstBeat = YES;
            SELF->_samplePos = curBeat * SELF->_samplesPerBeat + sampleOffset;
        }
        
        if (curBeat != prevBeat || SELF->_firstBeat) {
            for (int r = 0; r < GridRows; r++) {
                if (SELF->_grid[r][prevBeat]) {
                    SoundControllerStopNote(sc, r + BaseNote, offset);
                }
                
                if (SELF->_grid[r][curBeat]) {
                    SoundControllerPlayNote(sc, r + BaseNote, 1.0, offset);
                }
            }
        }
        
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
