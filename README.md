MusicMail
=========

MusicMail displays an example on using iOS ActivityView sharing method with a file that takes time to build.

Create a project and add the following files to Xcode project.

Frameworks Used:
CoreMedia
AVFoundation
MediaPLayer
UIKit
Foundation
CoreGraphics


This is a simple application that allows a user to select an audio file from their iPod library and send it via email as long as it is not a protected file.  This process takes time to complete, which has posed a problem with using UIActivityView.  This small application displays how UIActivityView can be used in conjunction with processing a file such as video, audio, etc…


The main part of the code to pay attention to is the AudioItemProvider.cpp file.  A wait  boolean is used to hold control of the main thread until the audio file is completed on a background thread.  A progress view is displayed showing the status of the audio file with the ProcessingRequestsViewController.cpp file.


All code is free to use at your disposal under EVA's Free Use License.