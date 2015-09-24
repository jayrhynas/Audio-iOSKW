//
//  SelectableView.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "SelectableView.h"

@implementation SelectableView

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
