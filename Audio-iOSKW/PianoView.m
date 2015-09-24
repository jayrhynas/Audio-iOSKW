//
//  Piano.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "PianoView.h"

#import "NSMapTable+Contains.h"


@interface PianoKey : UIControl
@property (strong, nonatomic) UIColor *normalBackgroundColor;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@end


static const int _numWhiteKeys = 8;
static const int _numBlackKeys = 5;

static const int _whitePattern[_numWhiteKeys] = {0, 2, 4, 5, 7, 9, 11, 12};
static const int _blackPattern[_numBlackKeys] = {1, 3, 6, 8, 10};

@interface PianoView ()
@property (strong, nonatomic) NSMapTable<UITouch *, NSNumber *> *activeKeys;
@end

@implementation PianoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;

    [self buildAllKeys];
    
    self.activeKeys = [NSMapTable mapTableWithKeyOptions:NSMapTableObjectPointerPersonality
                                            valueOptions:NSMapTableStrongMemory];
    
    return self;
}

- (void)buildAllKeys {
    const BOOL    drawBorders    = YES;
    const CGFloat pad            = 0;
    const CGFloat keyWidth       = (self.bounds.size.width - (_numWhiteKeys - 1) * pad) / _numWhiteKeys;
    const CGFloat whiteKeyHeight = self.bounds.size.height;
    const CGFloat blackKeyHeight = whiteKeyHeight * 2.0 / 3.0;
    
    self.tag = -1;
    
    // white keys
    for (int i = 0; i < _numWhiteKeys; i++) {
        CGRect frame = (CGRect){
            .origin.x    = (keyWidth + pad) * i,
            .origin.y    = 0,
            .size.width  = keyWidth,
            .size.height = whiteKeyHeight
        };
        
        PianoKey *key = [[PianoKey alloc] initWithFrame:frame];
        key.tag = _whitePattern[i];

        key.normalBackgroundColor   = [UIColor whiteColor];
        key.selectedBackgroundColor = [UIColor colorWithRed:0.203 green:0.368 blue:0.948 alpha:1.000];
        
        key.userInteractionEnabled = NO;
        key.multipleTouchEnabled = YES;
        
        if (drawBorders) {
            key.layer.borderColor = [UIColor blackColor].CGColor;
            key.layer.borderWidth = 1;
        }
        
        [self addSubview:key];
    }
    
    // black keys
    for (int i = 0; i < _numBlackKeys; i++) {
        CGRect frame = (CGRect){
            .origin.x    = (keyWidth + pad) / 2.0 + (keyWidth + pad) * i,
            .origin.y    = 0,
            .size.width  = keyWidth,
            .size.height = blackKeyHeight
        };
        
        if (i >= 2) {
            frame.origin.x += keyWidth + pad;
        }
        
        PianoKey *key = [[PianoKey alloc] initWithFrame:frame];
        key.tag = _blackPattern[i];

        key.normalBackgroundColor   = [UIColor blackColor];
        key.selectedBackgroundColor = [UIColor colorWithRed:0.203 green:0.368 blue:0.948 alpha:1.000];


        key.userInteractionEnabled = NO;
        key.multipleTouchEnabled = YES;

        if (drawBorders) {
            key.layer.borderColor = [UIColor whiteColor].CGColor;
            key.layer.borderWidth = 1;
        }
        
        [self addSubview:key];
    }
}

#pragma mark - Key Handling

- (void)activateKeyForTouch:(UITouch *)touch {
    UIView *target = [self hitTest:[touch locationInView:self] withEvent:nil];
    
    if (target && [target isKindOfClass:[PianoKey class]]) {
        PianoKey *key = (PianoKey *)target;
        
        NSNumber *oldKeyNum = [self.activeKeys objectForKey:touch];
        NSNumber *newKeyNum = @(key.tag);
        
        if (!oldKeyNum || oldKeyNum != newKeyNum) {
            if (![self.activeKeys containsObject:newKeyNum]) {
                [self.delegate keyStart:newKeyNum.intValue];
                
                key.selected = YES;
            }
            
            [self.activeKeys setObject:newKeyNum forKey:touch];
            
            if (oldKeyNum && ![self.activeKeys containsObject:oldKeyNum]) {
                [self.delegate keyStop:oldKeyNum.intValue];
                
                PianoKey *oldKey = (PianoKey *)[self viewWithTag:oldKeyNum.integerValue];
                oldKey.selected = NO;
            }
        }
    } else {
        [self deactivateKeyForTouch:touch];
    }
}

- (void)deactivateKeyForTouch:(UITouch *)touch {
    NSNumber *keyNum = [self.activeKeys objectForKey:touch];
    
    if (keyNum) {
        [self.activeKeys removeObjectForKey:touch];

        if (![self.activeKeys containsObject:keyNum]) {
            [self.delegate keyStop:keyNum.intValue];
            
            PianoKey *key = (PianoKey *)[self viewWithTag:keyNum.integerValue];
            if ([key isKindOfClass:[PianoKey class]]) {
                key.selected = NO;
            }
        }
    }
}

#pragma mark - Touch Handling

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        for (UIView *view in [self.subviews reverseObjectEnumerator]) {
            CGPoint subviewPoint = [self convertPoint:point toView:view];
            if ([view pointInside:subviewPoint withEvent:event]) {
                return view;
            }
        }
        return self;
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self activateKeyForTouch:touch];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self activateKeyForTouch:touch];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self deactivateKeyForTouch:touch];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self deactivateKeyForTouch:touch];
    }
}

@end


@implementation PianoKey

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    if (normalBackgroundColor == _normalBackgroundColor) return;
    
    _normalBackgroundColor = normalBackgroundColor;
    
    if (!self.selected) {
        self.backgroundColor = normalBackgroundColor;
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    if (selectedBackgroundColor == _selectedBackgroundColor) return;
    
    _selectedBackgroundColor = selectedBackgroundColor;
    
    if (self.selected) {
        self.backgroundColor = selectedBackgroundColor ?: self.normalBackgroundColor;
    }
}

- (void)setSelected:(BOOL)selected {
    BOOL wasSelected = super.selected;
    [super setSelected:selected];
    
    if (selected == wasSelected) return;
    
    if (self.selectedBackgroundColor) {
        self.backgroundColor = selected ? self.selectedBackgroundColor : self.normalBackgroundColor;
    }
}

@end