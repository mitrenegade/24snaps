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
-(void)enableFlash;
-(NSInteger)initialRollCount;
-(void)showFilmRoll;

@end
@interface CameraOverlayViewController : UIViewController <UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UIButton *buttonFlash;
    IBOutlet UIView *viewFilmAdvance;
    IBOutlet UIButton *buttonCapture;
    IBOutlet UIButton *buttonViewFinder;
    IBOutlet UIButton *buttonRoll;
    IBOutlet UIView *viewGlow;

    BOOL flash;
    int advancedCount;
    BOOL canScroll;

    IBOutlet UIImageView *viewBG;
    IBOutlet UIImageView *flashImage;
    IBOutlet UIImageView *scrollImage2;
    IBOutlet UIImageView *scrollImage3;

    IBOutlet NSLayoutConstraint *constraintViewFinderTop;
    IBOutlet NSLayoutConstraint *constraintViewFinderRight;
    IBOutlet NSLayoutConstraint *constraintViewFinderWidth;

    IBOutlet UIView *viewLabel;
    IBOutlet UIView *viewRotaterPrev, *viewRotaterCurr, *viewRotaterNext, *viewRotaterFuture;
    IBOutlet UILabel *labelCountPrev, *labelCountCurr, *labelCountNext, *labelCountFuture;
    NSInteger rollCount;

    BOOL isZooming;
}

@property (weak, nonatomic) id delegate;

-(IBAction)didClickButtonFlash:(id)sender;
-(IBAction)didClickCapture:(id)sender;
-(IBAction)didClickViewFinder:(id)sender;
-(IBAction)didClickFilmRoll:(id)sender;

-(float)viewFinderOffsetX;
-(float)viewFinderOffsetY;
-(float)viewFinderWidth;

-(void)refresh;
@end
