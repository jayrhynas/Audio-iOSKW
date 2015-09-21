//
//  ViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "ViewController.h"

#import "PianoView.h"

@interface ViewController () <PianoDelegate>

@end

@implementation ViewController

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
    NSLog(@"start %d", key);
}

- (void)keyStop:(int)key {
    NSLog(@"stop %d", key);
}

@end
