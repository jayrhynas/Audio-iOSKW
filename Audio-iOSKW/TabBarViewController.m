//
//  TabBarViewController.m
//  Audio-iOSKW
//
//  Created by Jayson Rhynas on 2015-09-24.
//  Copyright © 2015 jayrhynas. All rights reserved.
//

#import "TabBarViewController.h"

#import "SoundController.h"

@interface TabBarViewController ()

@property (strong, nonatomic) SoundController *soundController;

@end

@implementation TabBarViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (!(self = [super initWithCoder:coder])) return nil;
    
    self.soundController = [[SoundController alloc] init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIViewController *vc in self.viewControllers) {
        if ([vc respondsToSelector:@selector(setSoundController:)]) {
            [(id)vc setSoundController:self.soundController];
        }
    }
}

@end
