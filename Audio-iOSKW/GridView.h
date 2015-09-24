//
//  GridView.h
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    int row;
    int col;
} Cell;

@protocol GridDelegate

//- (void)cellOn:(Cell)cell;
//- (void)cellOff:(Cell)cell;

- (void)cellEnter:(Cell)cell;
- (void)cellLeave:(Cell)cell;

- (void)playbackStopped;

@end

@interface GridView : UIView

@property (weak, nonatomic) id<GridDelegate> delegate;
@property (nonatomic) BOOL playing;

@end
