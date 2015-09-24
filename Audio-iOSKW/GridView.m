//
//  GridView.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "GridView.h"

static const int _numRows = 13;
static const int _numCols = 16;

static const int _colorPattern[_numRows] = {0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0};
static NSString *_labels[_numRows] = {@"C", @"C♯/D♭", @"D", @"D♯/E♭", @"E", @"F", @"F♯/G♭", @"G", @"G♯/A♭", @"A", @"A♯/B♭", @"B", @"C"};

@implementation GridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self buildGrid];
    
    return self;
}

- (void)buildGrid {
    const CGSize size = {self.bounds.size.height / _numRows, self.bounds.size.height / _numRows};
    
    CGRect frame = self.bounds;
    frame.size.width = size.width;
    
    UIView *labels = [[UIView alloc] initWithFrame:frame];
    
    for (int r = 0; r < _numRows; r++) {
        CGPoint origin = {0, labels.frame.size.height - (r + 1) * size.height};
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){origin, size}];
        label.text = _labels[r];
        label.textAlignment = NSTextAlignmentCenter;
        
        [labels addSubview:label];
    }
    
    [self addSubview:labels];
    
    
    frame = self.bounds;
    frame.size.width = size.width * _numCols;
    frame.origin.x = labels.frame.origin.x + labels.frame.size.width + 20;
    
    UIView *grid = [[UIView alloc] initWithFrame:frame];
    
    grid.clipsToBounds = YES;
    grid.layer.cornerRadius = 10;
    grid.layer.borderWidth = 1;
    grid.layer.borderColor = [UIColor blackColor].CGColor;
    
    for (int c = 0; c < _numCols; c++) {
        for (int r = 0; r < _numRows; r++) {
            CGPoint origin = {c * size.width, grid.frame.size.height - (r + 1) * size.height};
            UIView *cell = [[UIView alloc] initWithFrame:(CGRect){origin, size}];

            cell.backgroundColor = _colorPattern[r] ? [UIColor colorWithWhite:0.7 alpha:1.0] : [UIColor whiteColor];
            
            cell.layer.borderColor = [UIColor blackColor].CGColor;
            cell.layer.borderWidth = 1;
            
            [grid addSubview:cell];
        }
    };
    
    [self addSubview:grid];

}

@end
