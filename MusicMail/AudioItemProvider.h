//
//  AudioItemProvider.h
//  MusicMail
//
//  Created by Doug Dimola on 4/28/13.
//  Copyright (c) 2013 Escape Velocity Apps. All rights reserved.


#import <UIKit/UIKit.h>

@interface AudioItemProvider : UIActivityItemProvider

@property (strong, retain) NSURL *completedUrl;

-(void)setViewController:(id)parentVc;
-(void)setFileName:(NSString*)name audioDuration:(NSNumber *)duration;

@end
