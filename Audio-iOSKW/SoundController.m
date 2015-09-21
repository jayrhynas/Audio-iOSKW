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
    MIDIChannelMode   = 0xB << 4,
    MIDIProgramChange = 0xC << 4,
    MIDIAllNotesOff   = 0x7B,
};

#define LogErr( result, fmt, ... ) \
{ \
    OSStatus error = (result); \
    if (error != noErr) { \
        NSLog(fmt @" [%d]", ##__VA_ARGS__, (int)error); \
    } \
}

@interface SoundController ()
@property (strong, nonatomic) AEAudioController *engine;

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

- (void)playNote:(int)note withVolume:(float)volume {
    UInt32 midiVol = volume * 127;
    LogErr(MusicDeviceMIDIEvent(self.samplerChannel.audioUnit, MIDINoteOn, note, midiVol, 0),
           @"Couldn't play note: %d", note);
}

- (void)stopNote:(int)note {
    LogErr(MusicDeviceMIDIEvent(self.samplerChannel.audioUnit, MIDINoteOff, note, 127, 0),
           @"Couldn't stop note: %d", note);
}
@end
