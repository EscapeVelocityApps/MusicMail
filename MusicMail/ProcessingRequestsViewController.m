//
//  ProcessingRequestsViewController.m
//  MusicMail
//
//  Created by Doug Dimola on 4/28/13.
//  Copyright (c) 2013 Escape Velocity Apps. All rights reserved.



#import "ProcessingRequestsViewController.h"

@interface ProcessingRequestsViewController ()
    @property (strong, nonatomic) UIImageView *rocketShipImage;
@end


@implementation ProcessingRequestsViewController

@synthesize processingLabel, processingProgressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set Background to white
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    // Add button to select file to email from iTunes Library.
    processingLabel = [[UILabel alloc] init];
    processingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    processingLabel.textColor = [UIColor blackColor];
    processingLabel.backgroundColor = [UIColor clearColor];
    processingLabel.text = NSLocalizedString(@"Creating new audio...", @"");
    [processingLabel setFont:[UIFont fontWithName:@"Noteworthy" size:24]];
    [self.view addSubview:processingLabel];
    
    processingProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    processingProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    processingProgressView.trackTintColor = [UIColor grayColor];
    processingProgressView.progressTintColor = [UIColor redColor];
    processingProgressView.progress = 0.0;
    [self.view addSubview:processingProgressView];
    
    _rocketShipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rocketShip.png"]];
    _rocketShipImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_rocketShipImage];
    
    // Set constraints for buttons
    [self.view setNeedsUpdateConstraints];
}



-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(processingLabel, processingProgressView, _rocketShipImage);
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"V:|-(>=30)-[processingLabel]-20-[processingProgressView]-30-[_rocketShipImage]-10-|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint
                   constraintsWithVisualFormat:@"|-30-[processingProgressView]-30-|"
                   options:0
                   metrics:nil
                   views:viewsDictionary];
    
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint
                   constraintsWithVisualFormat:@"|-50-[processingLabel]-50-|"
                   options:0
                   metrics:nil
                   views:viewsDictionary];
    
    [self.view addConstraints:constraints];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_rocketShipImage
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:1.0];
    
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:_rocketShipImage
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0
                                               constant:130.0];
    
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:_rocketShipImage
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0
                                               constant:150.0];
    
    [self.view addConstraint:constraint];

}

@end
