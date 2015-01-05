//
//  CameraOverlayViewController.m
//  DisposableCamera
//
//  Created by Bobby Ren on 1/5/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import "CameraOverlayViewController.h"
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
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [swipe setDelegate:self];
    [self.view addGestureRecognizer:swipe];

    advancedCount = 6;

    NSLog(@"Window bounds: %f %f", _appDelegate.window.bounds.size.width, _appDelegate.window.bounds.size.height);
    NSLog(@"Flash: %f %f", constraintFlashOffsetTop.constant, constraintFlashOffsetRight.constant);
    NSLog(@"Advance: %f %f", constraintAdvanceOffsetTop.constant, constraintAdvanceOffsetRight.constant);
    NSLog(@"Capture: %f %f", constraintCaptureOffsetTop.constant, constraintCaptureOffsetRight.constant);

    // hack: difficult to position the buttons and views exactly so do it programmatically for each screen size

    // iphone 6+
    if (_appDelegate.window.bounds.size.height == 736) {
        constraintFlashOffsetTop.constant = 234;
        constraintFlashOffsetRight.constant = 228;
        constraintAdvanceOffsetTop.constant = 3;
        constraintAdvanceOffsetRight.constant = -296;
        constraintCaptureOffsetTop.constant = 50;
        constraintCaptureOffsetRight.constant = 40;
    }

    // iphone 6
    if (_appDelegate.window.bounds.size.height == 667) {
        constraintFlashOffsetTop.constant = 200;
        constraintFlashOffsetRight.constant = 203;
        constraintAdvanceOffsetTop.constant = -10;
        constraintAdvanceOffsetRight.constant = -270;
        constraintCaptureOffsetTop.constant = 40;
        constraintCaptureOffsetRight.constant = 28;
    }

    // iphone 5/5s
    if (_appDelegate.window.bounds.size.height == 568) {
        constraintFlashOffsetTop.constant = 170;
        constraintFlashOffsetRight.constant = 170;
        constraintAdvanceOffsetTop.constant = -10;
        constraintAdvanceOffsetRight.constant = -220;
        constraintCaptureOffsetTop.constant = 28;
        constraintCaptureOffsetRight.constant = 26;
    }

    // iphone 4/4s
    if (_appDelegate.window.bounds.size.height == 480) {
        constraintFlashOffsetTop.constant = 139;
        constraintFlashOffsetRight.constant = 158;
        constraintAdvanceOffsetTop.constant = -24;
        constraintAdvanceOffsetRight.constant = -211;
        constraintCaptureOffsetTop.constant = 16;
        constraintCaptureOffsetRight.constant = 36;
    }

    [self toggleFlash:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark buttons

-(IBAction)didClickButtonFlash:(id)sender {
    if (!flash) {
        flash = YES;
        [self playFlash];
        [self toggleFlash:NO];
    }
    [self toggleFlash:YES];
}

-(IBAction)didClickCapture:(id)sender {
    if (advancedCount > 0)
        return;

    if (!flash) {
        [self playClick];
    }
    else {
        [self playClickFlash];
        [self toggleFlash:NO];
        [self toggleFlash:YES];
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
        [playerClickFlash setDelegate:self];
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
        [playerClickFlash setDelegate:self];
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

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Done");
}

#pragma mark flash
-(void)toggleFlash:(BOOL)isReady {
    if (!isReady) {
        [flashImage setAlpha:0];
    }
    else {
        [UIView animateWithDuration:1 animations:^{
            flashImage.alpha = 1;
        }];
    }
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

        [self doScrollAnimation];
    }
}

-(void)doScrollAnimation {
    [scrollImage2 setHidden:NO];
    [self performSelector:@selector(doScroll3) withObject:nil afterDelay:.1];
}

-(void)doScroll3 {
    [scrollImage3 setHidden:NO];
    [self performSelector:@selector(endScroll) withObject:nil afterDelay:.1];
}

-(void)endScroll {
    static BOOL repeat = YES;
    [scrollImage2 setHidden:YES];
    [scrollImage3 setHidden:YES];
    if (repeat) {
        repeat = NO;
        [self performSelector:@selector(doScrollAnimation) withObject:nil afterDelay:.1];
    }
    else {
        repeat = YES;
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
