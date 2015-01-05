//
//  CameraOverlayViewController.m
//  DisposableCamera
//
//  Created by Bobby Ren on 1/5/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import "CameraOverlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface CameraOverlayViewController ()
{
    AVAudioPlayer *playerFlash;
    AVAudioPlayer *playerClickFlash;
    AVAudioPlayer *playerClick;
    AVAudioPlayer *playerAdvance;
}

@end

@implementation CameraOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [swipe setDelegate:self];
    [self.view addGestureRecognizer:swipe];

    advancedCount = 6;

    NSLog(@"Window bounds: %f %f", _appDelegate.window.bounds.size.width, _appDelegate.window.bounds.size.height);
    NSLog(@"Flash: %f %f", constraintFlashOffsetTop.constant, constraintFlashOffsetRight.constant);
    NSLog(@"Advance: %f %f", constraintAdvanceOffsetTop.constant, constraintAdvanceOffsetRight.constant);

    // hack: difficult to position the buttons and views exactly so do it programmatically for each screen size

    // iphone 6+
    if (_appDelegate.window.bounds.size.width == 736) {
        constraintFlashOffsetTop.constant = 105;
        constraintFlashOffsetRight.constant = 220;
        constraintAdvanceOffsetTop.constant = 32;
        constraintAdvanceOffsetRight.constant = -15;
    }

    // iphone 6
    else if (_appDelegate.window.bounds.size.width == 667) {
        constraintFlashOffsetTop.constant = 98;
        constraintFlashOffsetRight.constant = 205;
        constraintAdvanceOffsetTop.constant = 19;
        constraintAdvanceOffsetRight.constant = -8;
    }

    // iphone 5/5s
    else if (_appDelegate.window.bounds.size.width == 568) {
        constraintFlashOffsetTop.constant = 76;
        constraintFlashOffsetRight.constant = 178;
        constraintAdvanceOffsetTop.constant = 20;
        constraintAdvanceOffsetRight.constant = 0;
    }

    // iphone 4/4s
    else if (_appDelegate.window.bounds.size.width == 480) {
        constraintFlashOffsetTop.constant = 85;
        constraintFlashOffsetRight.constant = 142;
        constraintAdvanceOffsetTop.constant = 28;
        constraintAdvanceOffsetRight.constant = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations
{
    //Because your app is only landscape, your view controller for the view in your
    // popover needs to support only landscape
    return UIInterfaceOrientationMaskLandscapeLeft;
}

#pragma mark buttons

-(IBAction)didClickButtonFlash:(id)sender {
    if (!flash) {
        flash = YES;
        [self playFlash];
    }
}

-(IBAction)didClickCapture:(id)sender {
    if (advancedCount > 0)
        return;

    if (!flash) {
        [self playClick];
    }
    else {
        [self playClickFlash];
    }
    advancedCount = MAX_ADVANCE_COUNT;
}

#pragma mark Sounds
-(void)playFlash {
    if (!playerFlash) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"cameraFlash"
                                             ofType:@"mp3"]];
        playerFlash = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:url
                       error:nil];
    }
    [playerFlash play];
}

-(void)playClickFlash {
    if (!playerClickFlash) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"cameraClickFlash"
                                             ofType:@"mp3"]];
        playerClickFlash = [[AVAudioPlayer alloc]
                            initWithContentsOfURL:url
                            error:nil];
    }
    [playerClickFlash play];
}

-(void)playClick {
    if (!playerClick) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"cameraClick"
                                             ofType:@"mp3"]];
        playerClick = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:url
                       error:nil];
    }
    [playerClick play];
}

-(void)playAdvance {
    if (!playerAdvance) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"cameraFilmAdvance"
                                             ofType:@"mp3"]];
        playerAdvance = [[AVAudioPlayer alloc]
                         initWithContentsOfURL:url
                         error:nil];
    }
    [playerAdvance play];
}

#pragma mark film advance
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (CGRectContainsPoint(viewFilmAdvance.frame, [touch locationInView:self.view])) {
        return YES;
    }
    return NO;
}
-(void)handleGesture:(UIGestureRecognizer *)gesture {
    if (advancedCount > 0) {
        [self playAdvance];
        advancedCount--;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
