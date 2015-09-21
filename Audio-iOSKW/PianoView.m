//
//  Piano.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "PianoView.h"

#import "NSMapTable+Contains.h"

static const int _numWhiteKeys = 7;
static const int _numBlackKeys = 5;

static const int _whitePattern[_numWhiteKeys] = {0, 2, 4, 5, 7, 9, 11};
static const int _blackPattern[_numBlackKeys] = {1, 3, 6, 8, 10};

@interface PianoView ()
@property (strong, nonatomic) NSMapTable<UITouch *, NSNumber *> *activeKeys;
@end

@implementation PianoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
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
    
    // white keys
    for (int i = 0; i < _numWhiteKeys; i++) {
        CGRect frame = (CGRect){
            .origin.x    = (keyWidth + pad) * i,
            .origin.y    = 0,
            .size.width  = keyWidth,
            .size.height = whiteKeyHeight
        };
        
        UIControl *key = [[UIControl alloc] initWithFrame:frame];
        key.tag = _whitePattern[i];

        key.backgroundColor = [UIColor whiteColor];

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
        
        UIControl *key = [[UIControl alloc] initWithFrame:frame];
        key.tag = _blackPattern[i];

        key.backgroundColor = [UIColor blackColor];
        
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
    
    if (target && target != self) {
        NSNumber *oldKeyNum = [self.activeKeys objectForKey:touch];
        NSNumber *newKeyNum = @(target.tag);
        
        if (!oldKeyNum || oldKeyNum != newKeyNum) {
            if (![self.activeKeys containsObject:newKeyNum]) {
                [self.delegate keyStart:newKeyNum.intValue];
            }
            
            [self.activeKeys setObject:newKeyNum forKey:touch];
            
            if (oldKeyNum && ![self.activeKeys containsObject:oldKeyNum]) {
                [self.delegate keyStop:oldKeyNum.intValue];
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
