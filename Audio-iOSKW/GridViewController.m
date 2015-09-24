//
//  GridViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "GridViewController.h"

#import "GridView.h"
#import "SoundController.h"

@interface GridViewController() <GridDelegate>

@property (strong, nonatomic) GridView *grid;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self setupGridView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:NO];
    
    self.grid.playing = NO;
}

- (void)setupGridView {
    const CGFloat pad = 20;
    CGRect frame = CGRectInset(self.view.bounds, pad, pad);
    frame.origin.y += 15;
    frame.size.height -= 64;
    
    GridView *grid = [[GridView alloc] initWithFrame:frame];
    
    grid.delegate = self;
    
    self.grid = grid;
    [self.view addSubview:grid];
}

- (void)cellEnter:(Cell)cell {
    [self.soundController playNote:cell.row + 60 withVolume:1.0];
}

- (void)cellLeave:(Cell)cell {
    [self.soundController stopNote:cell.row + 60];
}

- (void)playbackStopped {
    [self.soundController stopAllNotes];
}

@end
