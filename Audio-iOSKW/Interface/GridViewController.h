//
//  GridViewController.h
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaybackController;

@interface GridViewController : UIViewController

@property (weak, nonatomic) PlaybackController *playbackController;

@end

