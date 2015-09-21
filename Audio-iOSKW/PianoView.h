//
//  PianoView.h
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-20.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PianoDelegate

- (void)keyStart:(int)key;
- (void)keyStop:(int)key;

@end

@interface PianoView : UIView

@property (weak, nonatomic) id<PianoDelegate> delegate;

@end
