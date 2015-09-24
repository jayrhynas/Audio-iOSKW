//
//  PianoViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "PianoViewController.h"

#import "PianoView.h"
#import "SoundController.h"

@interface PianoViewController () <PianoDelegate>
@end

@implementation PianoViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self setupPianoView];
}

- (void)setupPianoView {
    const CGFloat pad = 20;
    CGRect frame = CGRectInset(self.view.bounds, pad, pad);
    frame.origin.y += 15;
    frame.size.height -= 64;
    
    PianoView *piano = [[PianoView alloc] initWithFrame:frame];
    
    piano.delegate = self;
    
    [self.view addSubview:piano];
}

- (void)keyStart:(int)key {
    [self.soundController playNote:key + 60 withVolume:1.0];
}

- (void)keyStop:(int)key {
    [self.soundController stopNote:key + 60];
}

@end
