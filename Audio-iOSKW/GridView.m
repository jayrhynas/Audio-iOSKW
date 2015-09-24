//
//  GridView.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "GridView.h"

#import "SelectableView.h"


static const int _numRows = 13;
static const int _numCols = 16;

static const int _colorPattern[_numRows] = {0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0};
static NSString *_labels[_numRows] = {@"C", @"C♯/D♭", @"D", @"D♯/E♭", @"E", @"F", @"F♯/G♭", @"G", @"G♯/A♭", @"A", @"A♯/B♭", @"B", @"C"};

@interface GridView () {
    BOOL _playing;
}

@property (strong, nonatomic) UIView *grid;
@property (strong, nonatomic) UIView *playhead;

@property (strong, nonatomic) NSMapTable<UITouch *, NSNumber *> *touches;

@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation GridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self buildGrid];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.touches = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality
                                            valueOptions:NSMapTableStrongMemory];
    
    return self;
}

- (void)buildGrid {
    const CGFloat pad = 20.0;
    
    const CGSize size = {self.bounds.size.height / _numRows, self.bounds.size.height / _numRows};
    
    CGRect frame = self.bounds;
    frame.size.width = size.width;
    
    UIView *labels = [[UIView alloc] initWithFrame:frame];
    
    for (int r = 0; r < _numRows; r++) {
        CGPoint origin = {0, labels.frame.size.height - (r + 1) * size.height};
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){origin, size}];
        label.tag = r;
        
        label.text = _labels[r];
        label.textAlignment = NSTextAlignmentCenter;
        
        [labels addSubview:label];
    }
    
    [self addSubview:labels];
    
    
    frame = self.bounds;
    frame.size.width = size.width * _numCols;
    frame.origin.x = labels.frame.origin.x + labels.frame.size.width + pad;
    
    UIView *grid = [[UIView alloc] initWithFrame:frame];
    
    grid.clipsToBounds = YES;
    grid.layer.cornerRadius = 10;
    grid.layer.borderWidth = 1;
    grid.layer.borderColor = [UIColor blackColor].CGColor;
    
    for (int c = 0; c < _numCols; c++) {
        for (int r = 0; r < _numRows; r++) {
            CGPoint origin = {c * size.width, grid.frame.size.height - (r + 1) * size.height};
            SelectableView *cell = [[SelectableView alloc] initWithFrame:(CGRect){origin, size}];
            cell.tag = r + (c * r);
            
            cell.normalBackgroundColor = _colorPattern[r] ? [UIColor colorWithWhite:0.7 alpha:1.0] : [UIColor whiteColor];
            cell.selectedBackgroundColor = [UIColor colorWithRed:0.203 green:0.368 blue:0.948 alpha:1.000];
            
            cell.userInteractionEnabled = NO;
            cell.multipleTouchEnabled = YES;

            cell.layer.borderColor = [UIColor blackColor].CGColor;
            cell.layer.borderWidth = 1;
            
            [grid addSubview:cell];
        }
    };
    
    self.grid = grid;
    [self addSubview:grid];

    
    frame = grid.bounds;
    frame.size.width = 3;

    UIView *playhead = [[UIView alloc] initWithFrame:frame];
    playhead.backgroundColor = [UIColor colorWithRed:0.196 green:0.262 blue:0.623 alpha:1.000];
    
    self.playhead = playhead;
    [grid addSubview:playhead];
    
    
    frame = self.bounds;
    frame.origin.x = grid.frame.origin.x + grid.frame.size.width + pad;
    frame.size.width = self.bounds.size.width - frame.origin.x;

    UIView *buttons = [[UIView alloc] initWithFrame:frame];
    
    {
        frame.origin.x = 0;
        frame.size.height = frame.size.width;
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.frame = frame;
        
        [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        
        [playButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttons addSubview:playButton];
        
        
        frame.origin.y += frame.size.height + pad;
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.frame = frame;
        
        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        
        [clearButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttons addSubview:clearButton];
    }
    
    [self addSubview:buttons];
}

- (void)update:(CADisplayLink *)displayLink {
    if (_playing) {
        CGFloat gridWidth = self.grid.bounds.size.width;
        
        CGRect frame = self.playhead.frame;
        frame.origin.x += 10.0;
        if (frame.origin.x > gridWidth) {
            frame.origin.x -= gridWidth;
        }
        
        self.playhead.frame = frame;
    }
}

#pragma mark - Button Handlers

- (void)playPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    _playing = sender.selected;
    
    if (!_playing) {
        CGRect frame = self.playhead.frame;
        frame.origin.x = 0;
        self.playhead.frame = frame;
    }
}

- (void)delete:(UIButton *)sender {
    for (SelectableView *subview in self.grid.subviews) {
        if (![subview isKindOfClass:[SelectableView class]]) continue;
        
        subview.selected = NO;
    }
    
    CGRect frame = self.playhead.frame;
    frame.origin.x = 0;
    self.playhead.frame = frame;
}

#pragma mark - Cell Handling

- (SelectableView *)hitTestCell:(UITouch *)touch {
    UIView *target = [self hitTest:[touch locationInView:self.grid] inView:self.grid];
    if (target && [target isKindOfClass:[SelectableView class]]) {
        return (SelectableView *)target;
    }
    return nil;
}

- (void)beginDrag:(UITouch *)touch {
    SelectableView *cell = [self hitTestCell:touch];
    if (!cell) return;
    
    BOOL newState = !cell.selected;
    cell.selected = newState;
    
    [self.touches setObject:@(newState) forKey:touch];
}

- (void)drag:(UITouch *)touch {
    SelectableView *cell = [self hitTestCell:touch];
    if (!cell) return;
    
    NSNumber *savedState = [self.touches objectForKey:touch];
    if (savedState) {
        cell.selected = [savedState boolValue];
    }
}

- (void)endDrag:(UITouch *)touch {
    [self.touches removeObjectForKey:touch];
}

#pragma mark - Touch Handling

- (UIView *)hitTest:(CGPoint)point inView:(UIView *)view {
    if ([self pointInside:point withEvent:nil]) {
        for (UIView *subview in [view.subviews reverseObjectEnumerator]) {
            CGPoint subviewPoint = [view convertPoint:point toView:subview];
            if ([subview pointInside:subviewPoint withEvent:nil]) {
                return subview;
            }
        }
        return self;
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self beginDrag:touch];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self drag:touch];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self endDrag:touch];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self endDrag:touch];
    }
}


@end
