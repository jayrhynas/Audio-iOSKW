//
//  GridViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "GridViewController.h"

#import "GridView.h"
#import "PlaybackController.h"

@interface GridViewController()

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
    grid.delegate = self.playbackController;
    
    self.grid = grid;
    [self.view addSubview:grid];
}

- (void)setPlaybackController:(PlaybackController *)playbackController {
    _playbackController = playbackController;
    self.grid.delegate = playbackController;
}

@end
