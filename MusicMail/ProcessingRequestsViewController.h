//
//  ProcessingRequestsViewController.h
//  MusicMail
//
//  Created by Doug Dimola on 4/28/13.
//  Copyright (c) 2013 Escape Velocity Apps. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ProcessingRequestsViewController : UIViewController {

    IBOutlet UILabel                    *processingLabel;
    IBOutlet UIProgressView             *processingProgressView;

}

@property (nonatomic, retain) IBOutlet UILabel *processingLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *processingProgressView;

@end