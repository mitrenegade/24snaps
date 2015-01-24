//
//  CameraOverlayViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 1/5/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define INITIAL_ADVANCE_COUNT 0 // new camera roll
#define MAX_ADVANCE_COUNT 4

@protocol CameraOverlayDelegate <NSObject>

-(void)zoomIn;
-(void)zoomOut:(BOOL)animated;
-(void)capture;
-(NSInteger)initialRollCount;

@end
@interface CameraOverlayViewController : UIViewController <UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UIButton *buttonFlash;
    IBOutlet UIView *viewFilmAdvance;
    IBOutlet UIButton *buttonCapture;
    IBOutlet UIButton *buttonViewFinder;
    
    BOOL flash;
    int advancedCount;

    IBOutlet UIImageView *viewBG;
    IBOutlet UIImageView *flashImage;
    IBOutlet UIImageView *scrollImage2;
    IBOutlet UIImageView *scrollImage3;

    IBOutlet UIView *viewLabel;
    IBOutlet UIView *viewRotaterPrev, *viewRotaterCurr, *viewRotaterNext;
    IBOutlet UILabel *labelCountPrev, *labelCountCurr, *labelCountNext;
    NSInteger rollCount;

    BOOL isZooming;
}

@property (weak, nonatomic) id delegate;

-(IBAction)didClickButtonFlash:(id)sender;
-(IBAction)didClickCapture:(id)sender;
-(IBAction)didClickViewFinder:(id)sender;
@end
