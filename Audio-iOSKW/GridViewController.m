//
//  GridViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "GridViewController.h"

#import "GridView.h"

@interface GridViewController ()

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self setupGridView];
}

- (void)setupGridView {
    const CGFloat pad = 20;
    CGRect frame = CGRectInset(self.view.bounds, pad, pad);
    frame.origin.y += 15;
    frame.size.height -= 64;
    
    GridView *grid = [[GridView alloc] initWithFrame:frame];
    
//    piano.delegate = self;
    
    [self.view addSubview:grid];
}


@end
