//
//  MusicMailViewController.m
//  MusicMail
//
//  Created by Doug Dimola on 4/28/13.
//  Copyright (c) 2013 Escape Velocity Apps. All rights reserved.


#import "MusicMailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioItemProvider.h"

@interface MusicMailViewController () <MPMediaPickerControllerDelegate>
    @property (weak, nonatomic) UIButton *selectButton;
@end

@implementation MusicMailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Set Background to white
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    // Add button to select file to email from iTunes Library.
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *shareButtonImage = [UIImage imageNamed:@"ShareButton.png"];
    [self.selectButton setImage:shareButtonImage forState:UIControlStateNormal];
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.selectButton setTitle:@"Select Audio To Share" forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectButton];
    
    // Set constraints for buttons
    [self.view setNeedsUpdateConstraints];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.selectButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:250.0];
    
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.selectButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:300.0];
    
    [self.view addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self.selectButton
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0
                                               constant:1.0];
    
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.selectButton
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:1.0];
    
    [self.view addConstraint:constraint];
}

#pragma mark - Button Handles

-(void)selectButton:(id)sender
{
    // Show iTunes Library to select file to share.
    MPMediaType pickedTypes = MPMediaTypeAnyAudio;
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:pickedTypes];
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems:NO];
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    [picker setPrompt: NSLocalizedString(@"Select Audio File to Share", @"Prompt in media item picker")];
    
    [self presentViewController:picker animated:YES completion: nil];
}

#pragma mark - Share Code Block

-(void) shareAudioFileSelected:(MPMediaItemCollection *)collection
{
    // Check if file is protected, if it is not proceed with copying it to Email.
    NSURL *urlOfAsset = [(collection.items)[0] valueForProperty: MPMediaItemPropertyAssetURL];
    if ([self IsAudioFileProtected:urlOfAsset]) {
        UIAlertView *failureAlert = [[UIAlertView alloc]
                                     initWithTitle :NSLocalizedString(@"File is Protected", @"Protected File")
                                     message: NSLocalizedString(@"This file is protected and cannot be sent via Email.", @"This file is protected and cannot be sent via Email")
                                     delegate : nil
                                     cancelButtonTitle:NSLocalizedString(@"OK",@"Okay, I understand")
                                     otherButtonTitles:nil];
        [failureAlert show];
        return;
    }
    
    // Using UIActivity View Controller
    AudioItemProvider *fileToShare = [[AudioItemProvider alloc] initWithPlaceholderItem:urlOfAsset];
    [fileToShare setFileName:[(collection.items)[0] valueForProperty: MPMediaItemPropertyTitle]
               audioDuration:[(collection.items)[0] valueForProperty: MPMediaItemPropertyPlaybackDuration]];
    NSArray *activityItems = @[fileToShare];
    UIActivityViewController *activityController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    
    activityController.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeMessage, UIActivityTypeCopyToPasteboard];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        // Finished sharing, now delete the created audio file.
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:fileToShare.completedUrl error:&error];
    }];
    
    [fileToShare setViewController:activityController];
    
    [self presentViewController:activityController animated:YES completion:nil];
    
}

-(bool)IsAudioFileProtected:(NSURL*)assetURL {
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    NSArray *tracks = [songAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *track = tracks[0];
    id desc = (track.formatDescriptions)[0];
    
    const AudioStreamBasicDescription *audioDesc = CMAudioFormatDescriptionGetStreamBasicDescription((__bridge CMAudioFormatDescriptionRef)desc);
    
    if (!audioDesc) {
        return YES;
    }
    return NO;
}


#pragma mark Media Picker Delegate
- (void) mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self shareAudioFileSelected:collection];
    }];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
