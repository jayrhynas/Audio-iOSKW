//
//  TabBarViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "TabBarViewController.h"

#import "SoundController.h"
#import "PlaybackController.h"

@interface TabBarViewController ()

@property (strong, nonatomic) SoundController    *soundController;
@property (strong, nonatomic) PlaybackController *playbackController;

@end

@implementation TabBarViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (!(self = [super initWithCoder:coder])) return nil;
    
    self.soundController    = [[SoundController alloc] init];
    self.playbackController = [[PlaybackController alloc] initWithSoundController:self.soundController];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIViewController *vc in self.viewControllers) {
        if ([vc respondsToSelector:@selector(setSoundController:)]) {
            [(id)vc setSoundController:self.soundController];
        }
        if ([vc respondsToSelector:@selector(setPlaybackController:)]) {
            [(id)vc setPlaybackController:self.playbackController];
        }
    }
}

@end
