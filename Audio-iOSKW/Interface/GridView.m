//
//  GridView.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "GridView.h"

#import "SelectableView.h"
#import "Constants.h"

static const int _colorPattern[GridRows] = {0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0};
static NSString *_labels[GridRows] = {@"C", @"C♯/D♭", @"D", @"D♯/E♭", @"E", @"F", @"F♯/G♭", @"G", @"G♯/A♭", @"A", @"A♯/B♭", @"B", @"C"};


Cell CellFromTag(NSInteger tag) {
    return (Cell){tag % GridRows, (int)tag / GridRows};
}

NSInteger TagFromCell(Cell cell) {
    return cell.row + cell.col * GridRows;
}

@interface GridView () <UITextFieldDelegate>

@property (strong, nonatomic) UIView *grid;
@property (strong, nonatomic) UIView *playhead;
@property (strong, nonatomic) UIButton *playButton;

@property (strong, nonatomic) NSMapTable<UITouch *, NSNumber *> *touches;

@property (strong, nonatomic) CADisplayLink *displayLink;

@property (nonatomic) int bpm;

@end

@implementation GridView

#pragma mark - Properties


- (void)setPlaying:(BOOL)playing {
    if (playing == _playing) return;
    _playing = playing;
    
    self.playButton.selected = _playing;
    
    if (!_playing) {
        CGRect frame = self.playhead.frame;
        frame.origin.x = -5;
        self.playhead.frame = frame;
    }
    
    [self.delegate playbackToggled:_playing];
}

- (void)setBpm:(int)bpm {
    if (bpm == _bpm) return;
    _bpm = bpm;
    
    [self.delegate bpmChanged:bpm];
}

#pragma mark - Initialization & Setup

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    _bpm = DefaultBPM;
    
    [self buildGrid];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.touches = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality
                                            valueOptions:NSMapTableStrongMemory];
    
    return self;
}

- (void)buildGrid {
    const CGFloat pad = 20.0;
    
    const CGSize size = {self.bounds.size.height / GridRows, self.bounds.size.height / GridRows};
    
    CGRect frame = self.bounds;
    frame.size.width = size.width;
    
    UIView *labels = [[UIView alloc] initWithFrame:frame];
    
    for (int r = 0; r < GridRows; r++) {
        CGPoint origin = {0, labels.frame.size.height - (r + 1) * size.height};
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){origin, size}];
        label.tag = r;
        
        label.text = _labels[r];
        label.textAlignment = NSTextAlignmentCenter;
        
        [labels addSubview:label];
    }
    
    [self addSubview:labels];
    
    
    frame = self.bounds;
    frame.size.width = size.width * GridCols;
    frame.origin.x = labels.frame.origin.x + labels.frame.size.width + pad;
    
    UIView *grid = [[UIView alloc] initWithFrame:frame];
    
    grid.clipsToBounds = YES;
    grid.layer.cornerRadius = 10;
    grid.layer.borderWidth = 1;
    grid.layer.borderColor = [UIColor blackColor].CGColor;
    
    for (int c = 0; c < GridCols; c++) {
        for (int r = 0; r < GridRows; r++) {
            CGPoint origin = {c * size.width, grid.frame.size.height - (r + 1) * size.height};
            SelectableView *cell = [[SelectableView alloc] initWithFrame:(CGRect){origin, size}];
            cell.tag = TagFromCell((Cell){r, c});
            
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
    frame.origin.x = -5;
    
    UIView *playhead = [[UIView alloc] initWithFrame:frame];
    playhead.tag = -1;
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
        
        self.playButton = playButton;
        [buttons addSubview:playButton];
        
        
        frame.origin.y += frame.size.height + pad;
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.frame = frame;
        
        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        
        [clearButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttons addSubview:clearButton];
        
        
        frame.origin.y += frame.size.height + pad;
        
        UITextField *bpm = [[UITextField alloc] initWithFrame:frame];
        bpm.text = [NSString stringWithFormat:@"%d BPM", self.bpm];
        bpm.textAlignment = NSTextAlignmentCenter;
        bpm.keyboardType = UIKeyboardTypeNumberPad;
        bpm.returnKeyType = UIReturnKeyDone;
        bpm.delegate = self;
        
        [buttons addSubview:bpm];
    }
    
    [self addSubview:buttons];
}

- (void)update:(CADisplayLink *)displayLink {
    if (_playing) {
        CGFloat gridWidth = self.grid.bounds.size.width;
        CGFloat colWidth = gridWidth / GridCols;
        
        NSTimeInterval secs = displayLink.duration;
        CGFloat pointsPerBeat = colWidth * 4;
        CGFloat inc = pointsPerBeat * ((float)self.bpm / 60.0) * secs;
        
        CGRect frame = self.playhead.frame;
        CGRect oldFrame = frame;
        
        frame.origin.x += inc;
        if (frame.origin.x > gridWidth) {
            frame.origin.x -= gridWidth;
        }
        
        self.playhead.frame = frame;
        
        int oldCol = floor(oldFrame.origin.x / colWidth);
        int newCol = floor(frame.origin.x / colWidth);
        
        if (oldCol != newCol) {
            int cols[2] = {oldCol, newCol};
            
            for (int i = 0; i < 2; i++) {
                int c = cols[i];
                if (c < 0 || c >= GridCols) continue;
                
                for (int r = 0; r < GridRows; r++) {
                    NSInteger index = TagFromCell((Cell){r, c});
                    SelectableView *cell = self.grid.subviews[index];
                    
                    if (cell.selected) {
                        if (c == oldCol) {
                            [self.delegate cellLeave:(Cell){r, c}];
                        } else {
                            [self.delegate cellEnter:(Cell){r, c}];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = [textField.text stringByReplacingOccurrencesOfString:@" BPM" withString:@""];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *text = [textField.text stringByReplacingOccurrencesOfString:@" BPM" withString:@""];
    int bpm = [text intValue];
    bpm = MIN(MAX(bpm, 10), 300);
    
    self.bpm = bpm;
    textField.text = [NSString stringWithFormat:@"%d BPM", bpm];
}

#pragma mark - Button Handlers

- (void)playPause:(UIButton *)sender {
    self.playing = !self.playing;
}

- (void)delete:(UIButton *)sender {
    
    for (SelectableView *subview in self.grid.subviews) {
        if (![subview isKindOfClass:[SelectableView class]]) continue;
        
        subview.selected = NO;
        [self.delegate cellToggled:CellFromTag(subview.tag) toState:subview.selected];
    }
    
    self.playing = NO;
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
    
    [self.delegate cellToggled:CellFromTag(cell.tag) toState:cell.selected];
}

- (void)drag:(UITouch *)touch {
    SelectableView *cell = [self hitTestCell:touch];
    if (!cell) return;
    
    NSNumber *savedState = [self.touches objectForKey:touch];
    if (savedState) {
        cell.selected = [savedState boolValue];
        
        [self.delegate cellToggled:CellFromTag(cell.tag) toState:cell.selected];
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
