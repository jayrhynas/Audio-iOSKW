//
//  ViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "ViewController.h"

#import "PianoView.h"
#import "SoundController.h"

@interface ViewController () <PianoDelegate>

@property (strong, nonatomic) SoundController *soundController;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    self.soundController = [[SoundController alloc] init];
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self setupPianoView];
}

- (void)setupPianoView {
    const CGFloat pad = 20;
    CGRect frame = CGRectInset(self.view.bounds, pad, 0);
    frame.origin.y += 50;
    frame.size.height -= frame.origin.y + pad;
    
    PianoView *piano = [[PianoView alloc] initWithFrame:frame];
    
    piano.clipsToBounds = YES;
    piano.layer.cornerRadius = 10;
    piano.layer.borderWidth = 1;
    piano.layer.borderColor = [UIColor blackColor].CGColor;
    
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
