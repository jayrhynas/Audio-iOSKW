//
//  SoundController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "SoundController.h"

#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

typedef NS_ENUM(UInt32, MIDIMessage) {
    MIDINoteOn        = 0x9 << 4,
    MIDINoteOff       = 0x8 << 4,
};

#if DEBUG
#define LogErr( result, fmt, ... ) \
{ \
    OSStatus error = (result); \
    if (error != noErr) { \
        NSLog(fmt @" [%d]", ##__VA_ARGS__, (int)error); \
    } \
}
#else
#define LogErr( ... ) {}
#endif

@interface SoundController () {
    AudioUnit _samplerUnit;
}

@property (strong, nonatomic, readwrite) AEAudioController *engine;
@property (strong, nonatomic) AEAudioUnitChannel *samplerChannel;
@end

@implementation SoundController

#pragma mark - Setup

- (instancetype)init {
    if (!(self = [super init])) return nil;
    
    [self setupEngine];
    
    [self.engine start:nil];
    
    return self;
}

- (void)setupEngine {
    self.engine = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]];
    
    AudioComponentDescription samplerDesc = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                            kAudioUnitType_MusicDevice,
                                                                            kAudioUnitSubType_Sampler);
    
    self.samplerChannel = [[AEAudioUnitChannel alloc] initWithComponentDescription:samplerDesc];
    [self.engine addChannels:@[self.samplerChannel]];
    
    _samplerUnit = self.samplerChannel.audioUnit;
    
    [self loadAUPreset:[[NSBundle mainBundle] URLForResource:@"cross" withExtension:@"aupreset" subdirectory:@"Sounds/cross"]];
}

#pragma mark - Instruments

- (void)loadAUPreset:(NSURL *)aupresetURL
{
    NSDictionary *aupresetDict = [NSDictionary dictionaryWithContentsOfURL:aupresetURL];
    if (!aupresetDict) {
        NSLog(@"failed to load aupreset from disk: %@", [aupresetURL absoluteString]);
    }
    
    LogErr(AudioUnitSetProperty(self.samplerChannel.audioUnit,
                                kAudioUnitProperty_ClassInfo,
                                kAudioUnitScope_Global,
                                0,
                                &aupresetDict,
                                sizeof(aupresetDict)),
           @"Couldn't load AUPreset: %@", aupresetURL);
}

- (void)loadSoundFont:(NSURL *)soundFontURL
{
    AUSamplerInstrumentData instrument = {
        .fileURL        = (__bridge CFURLRef)soundFontURL,
        .instrumentType = kInstrumentType_SF2Preset,
        .bankMSB        = kAUSampler_DefaultMelodicBankMSB,
        .bankLSB        = kAUSampler_DefaultBankLSB,
        .presetID       = 0
    };
    
    LogErr(AudioUnitSetProperty(self.samplerChannel.audioUnit,
                                kAUSamplerProperty_LoadInstrument,
                                kAudioUnitScope_Global,
                                0,
                                &instrument,
                                sizeof(instrument)),
           @"Couldn't load SoundFont: %@", soundFontURL);
}

#pragma mark - Notes

void SoundControllerPlayNote(SoundController* sc, int note, float volume, UInt32 offset) {
    UInt32 midiVol = volume * 127;
    LogErr(MusicDeviceMIDIEvent(sc->_samplerUnit, MIDINoteOn, note, midiVol, offset),
           @"Couldn't play note: %d", note);
}

void SoundControllerStopNote(SoundController* sc, int note, UInt32 offset) {
    LogErr(MusicDeviceMIDIEvent(sc->_samplerUnit, MIDINoteOff, note, 127, offset),
           @"Couldn't stop note: %d", note);
}

void SoundControllerStopAllNotes(SoundController* sc, UInt32 offset) {
    for (int i = 0; i < 128; i++) {
        SoundControllerStopNote(sc, i, offset);
    }
}

- (void)playNote:(int)note withVolume:(float)volume {
    SoundControllerPlayNote(self, note, volume, 0);
}

- (void)stopNote:(int)note {
    SoundControllerStopNote(self, note, 0);
}

- (void)stopAllNotes {
    SoundControllerStopAllNotes(self, 0);
}

@end
