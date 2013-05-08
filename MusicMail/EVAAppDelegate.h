//
//  EVAAppDelegate.h
//  MusicMail
//
//  Created by Doug Dimola on 4/28/13.
//  Copyright (c) 2013 Escape Velocity Apps. All rights reserved.


#import <UIKit/UIKit.h>

@class MusicMailViewController;

@interface EVAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MusicMailViewController *viewController;

@end
