//
//  AudioItemProvider.m
//  MusicMail
//
//  Created by Doug Dimola on 4/28/13.
//  Copyright (c) 2013 Escape Velocity Apps. All rights reserved.



#import "AudioItemProvider.h"
#import <AVFoundation/AVFoundation.h>
#import "ProcessingRequestsViewController.h"


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface AudioItemProvider ()
    @property (readwrite, nonatomic) bool wait;
    @property (strong, nonatomic) NSString *fileName;
    @property (readwrite, nonatomic) float totalDuration;
    @property (readwrite, nonatomic) float currentTime;

    @property (strong, retain) UIViewController *parentViewController;
    @property (strong, retain) ProcessingRequestsViewController *processViewController;
@end

@implementation AudioItemProvider

@synthesize completedUrl;

-(void)setViewController:(id)parentVc
{
    self.parentViewController = parentVc;
}

-(void)setFileName:(NSString*)name audioDuration:(NSNumber *)duration
{
    self.fileName = name;
    self.totalDuration = [duration floatValue];
}

-(void)createNewAudioFile
{
    self.wait = true;
    AVURLAsset *trackAsset = [AVURLAsset URLAssetWithURL:self.placeholderItem options:nil];
    NSError *assetError = nil;
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:trackAsset error:&assetError];
    
    CMTime startingTime = CMTimeMake (0, 1);
    CMTime duration = CMTimeMake (self.totalDuration, 1);
    assetReader.timeRange = CMTimeRangeMake(startingTime, duration);
	
    if (assetError) {
		NSLog (@"Reader Alloc error: %@", assetError);
		return;
	}
    
    AVAssetReaderOutput *assetReaderOutput =
	[AVAssetReaderAudioMixOutput
     assetReaderAudioMixOutputWithAudioTracks:trackAsset.tracks
     audioSettings: nil];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output.");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
	
	NSString *filePath = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, self.fileName];
	
    while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    
    NSURL *exportURL = [NSURL fileURLWithPath:filePath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL fileType:AVFileTypeAppleM4A error:&assetError];
    
    if (assetError) {
        NSLog (@"Writer Alloc error: %@", assetError);
        return;
    }
    
    // Create an m4a.
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *outputSettings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                     AVNumberOfChannelsKey: @2,
                                     AVSampleRateKey: @44100.0f,
                                     AVChannelLayoutKey: [ NSData dataWithBytes: &channelLayout length: sizeof( AudioChannelLayout ) ], AVEncoderBitRateKey: @64000};
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input");
        return;
    }
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    AVAssetTrack *soundTrack = (trackAsset.tracks)[0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    dispatch_queue_t mediaInputQueue =
	dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer =
             [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 
                 // update ui
                 convertedByteCount +=
                 CMSampleBufferGetTotalSampleSize (nextBuffer);
                 
                 CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
                 CMSampleBufferGetSampleTimingInfo(nextBuffer, 0, &timimgInfo);
                 
                 self.currentTime = CMTimeGetSeconds(timimgInfo.presentationTimeStamp) - 0;
             } else {
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWritingWithCompletionHandler:^(void) {
                     [assetReader cancelReading];
                     self.completedUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
                     
                     [self performSelectorOnMainThread:@selector(dismissOverallStatusView) withObject:nil waitUntilDone:NO];
                 }];
                 
                 break;
             }
         }
	 }];
}

- (id)item
{
    self.wait = true;
    
    [self performSelectorOnMainThread:@selector(dismissAndLoadProgressView) withObject:nil waitUntilDone:NO];
    
    while (self.wait) {
        [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:NO];
    }
    return self.completedUrl;
}


-(void)dismissAndLoadProgressView
{
    self.processViewController = [[ProcessingRequestsViewController alloc] initWithNibName:nil bundle:nil];
    self.processViewController.processingProgressView.progress = 0.0;
    self.currentTime = 0;
    
    [self.parentViewController presentViewController:self.processViewController animated:TRUE completion:^(){
        [self createNewAudioFile];
    }];
}


-(void)updateProgressView
{
    self.processViewController.processingProgressView.progress = self.currentTime/self.totalDuration;
}

-(void)dismissOverallStatusView
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^(){
        self.wait = false;
    }];
}

@end
