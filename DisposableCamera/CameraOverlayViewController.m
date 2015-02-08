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

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [swipe setDelegate:self];
    [self.view addGestureRecognizer:swipe];

    viewLabel.layer.cornerRadius = viewLabel.frame.size.width/4;
    viewLabel.layer.borderWidth = 1;
    viewLabel.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    labelCountCurr.transform = CGAffineTransformMakeRotation(M_PI_2);
    labelCountPrev.transform = CGAffineTransformMakeRotation(M_PI_2);
    labelCountNext.transform = CGAffineTransformMakeRotation(M_PI_2);
    labelCountFuture.transform = CGAffineTransformMakeRotation(M_PI_2);

    for (UILabel *label in @[labelCountCurr, labelCountFuture, labelCountNext, labelCountPrev]) {
        label.font = [UIFont boldSystemFontOfSize:12];
    }

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] init]; // prevent user zoom
    [self.view addGestureRecognizer:pinch];

#if !TESTING
    buttonFlash.backgroundColor = [UIColor clearColor];
    buttonViewFinder.backgroundColor = [UIColor clearColor];
    viewFilmAdvance.backgroundColor = [UIColor clearColor];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCaptured:) name:@"image:captured" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"appdelegate:returnFromBackground" object:nil];
    rollCount = [self.delegate initialRollCount];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"film:state"]) {
        filmState = [[NSUserDefaults standardUserDefaults] integerForKey:@"film:state"];
        if (filmState == FilmStateReady) {
            filmState = FilmStateInitialWound;
        }
    }
    else {
        filmState = FilmStateNeedsWinding;
        [[NSUserDefaults standardUserDefaults] setInteger:filmState forKey:@"film:state"];
    }

    [self refresh];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"image:captured" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appdelegate:returnFromBackground" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh {
    [self toggleFlash:NO];

    if (filmState == FilmStateNeedsWinding) {
        [self toggleCapture:NO];
    }
    else {
        if (rollCount < MAX_ROLL_SIZE) {
            [self toggleCapture:YES];
        }
        else {
            [self toggleCapture:NO];
        }
    }

    if (filmState == FilmStateInitialWound) {
        [self setLabelCountPosition:4];
    }
    else {
        [self setLabelCountPosition:0];
    }

    if (rollCount < MAX_ROLL_SIZE) {
#if TESTING == 2
        [buttonRoll setHidden:NO];
#else
        [buttonRoll setHidden:YES];
#endif
        [buttonCapture setHidden:NO];
    }
    else {
        [buttonRoll setHidden:NO];
        [buttonCapture setHidden:YES];
    }

    viewGlow.alpha = 0;
}

#pragma mark buttons

-(IBAction)didClickButtonFlash:(id)sender {
    if (!flash) {
        flash = YES;
        [self playFlash];
        [self toggleFlash:NO];

        [PFAnalytics trackEventInBackground:@"turnFlashOn" block:nil];
    }
    [self toggleFlash:YES];
}

-(IBAction)didClickCapture:(id)sender {
#if TESTING == 2
    [self warnForFilm];
    return;
#endif

    if (filmState == FilmStateNeedsWinding) {
        [self warnForAdvance];
        return;
    }
    else if (rollCount == MAX_ROLL_SIZE) {
        [self warnForFilm];
        return;
    }

    // doesn't matter if the camera outcome fails, always toggle the button and "advance" the count
    [self toggleCapture:NO];
    filmState = FilmStateNeedsWinding;
    [[NSUserDefaults standardUserDefaults] setInteger:filmState forKey:@"film:state"];

    [self playClick];
    if (flash) {
        [self toggleFlash:NO];
    }
    // tell camera to actually try to capture
    [self.delegate capture];
}

-(IBAction)didClickFilmRoll:(id)sender {
    // opens roll and reveals existing images
    [self.delegate showFilmRoll];
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

    // if tactile feedback is desired. doesn't feel too authentic.
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)toggleCapture:(BOOL)canCapture {
    if (!canCapture) {
        [buttonCapture setAlpha:.5];
    }
    else {
        [buttonCapture setAlpha:1];
    }
}

#pragma mark flash
-(void)toggleFlash:(BOOL)isReady {
    if (!isReady) {
        [flashImage setAlpha:0];
    }
    else {
        [UIView animateWithDuration:1 animations:^{
            flashImage.alpha = 1;
        } completion:^(BOOL finished) {
            [self.delegate enableFlash];
        }];
    }
}

#pragma mark film advance
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return filmState == FilmStateNeedsWinding;
}

-(void)handleGesture:(UIGestureRecognizer *)gesture {
    if (isZooming)
        return;
    if (rollCount > MAX_ROLL_SIZE)
        return;
    if (!CGRectContainsPoint(viewFilmAdvance.frame, [gesture locationInView:self.view])) {
        return;
    }

    if (filmState == FilmStateNeedsWinding) {
        [self advance];
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
    [scrollImage2 setHidden:YES];
    [scrollImage3 setHidden:YES];
}

-(void)advance {
    static int advancedCount = 0;
    [self playAdvance];

    advancedCount = advancedCount + 1;
    [self setLabelCountPosition:advancedCount];
    [self doScrollAnimation];

    if (advancedCount >= 4 && rollCount <= MAX_ROLL_SIZE) {
        filmState = FilmStateReady;
        [[NSUserDefaults standardUserDefaults] setInteger:filmState forKey:@"film:state"];
        [self toggleCapture:YES];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(advance) object:nil];
        advancedCount = 0;
    }
    else {
        [self doScrollAnimation];
        [self performSelector:@selector(advance) withObject:nil afterDelay:.4];
    }
}

#pragma mark Viewfinder
-(IBAction)didClickViewFinder:(id)sender {
    if (!isZooming) {
        [self lookInViewFinder];
    }
    else {
        [self stopLookingInViewFinder];
    }
}

-(void)lookInViewFinder {
    [buttonFlash setUserInteractionEnabled:isZooming];
    [buttonFlash setHidden:!isZooming];
    [viewFilmAdvance setUserInteractionEnabled:isZooming];
    [flashImage setHidden:!isZooming];
    [scrollImage2 setHidden:!isZooming];
    [scrollImage3 setHidden:!isZooming];

    float tx = self.view.frame.size.width/2 - buttonViewFinder.center.x;
    float ty = self.view.frame.size.height/2 - buttonViewFinder.center.y;
    NSLog(@"x y: %f %f", buttonViewFinder.center.x, buttonViewFinder.center.y);
    float scale = 7;

    // scale and translate so that the center of the viewFinder is enlarged and centered
    // transform for viewFinder and background/view must be composed differently; this is due to autolayout
    [self.delegate zoomIn];
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformTranslate(viewBG.transform, tx*scale, ty*scale), scale, scale);
    CGAffineTransform transform2 = CGAffineTransformScale(CGAffineTransformTranslate(buttonViewFinder.transform, tx, 0), scale, scale);

    viewLabel.alpha = 0;
    buttonRoll.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        viewBG.transform = transform;
        buttonViewFinder.transform = transform2;
        buttonViewFinder.alpha = .25;
    } completion:^(BOOL finished) {
        isZooming = !isZooming;
    }];

    [PFAnalytics trackEventInBackground:@"tapViewfinder" dimensions:@{@"action": @"look in"} block:nil];
}

-(void)stopLookingInViewFinder {
    [self.delegate zoomOut:YES];
    [UIView animateWithDuration:.5 animations:^{
        viewBG.transform = CGAffineTransformIdentity;
        buttonViewFinder.transform = CGAffineTransformIdentity;
        buttonViewFinder.alpha = 1;
    } completion:^(BOOL finished) {
        viewLabel.alpha = 1;
        buttonRoll.alpha = 1;
        
        [buttonFlash setUserInteractionEnabled:isZooming];
        [buttonFlash setHidden:!isZooming];
        [viewFilmAdvance setUserInteractionEnabled:isZooming];
        [flashImage setHidden:!isZooming];
        [scrollImage2 setHidden:!isZooming];
        [scrollImage3 setHidden:!isZooming];

        isZooming = !isZooming;
    }];

    [PFAnalytics trackEventInBackground:@"tapViewfinder" dimensions:@{@"action": @"look away"} block:nil];
}

-(float)viewFinderOffsetX {
    return buttonViewFinder.center.x - self.view.center.x;
}

-(float)viewFinderOffsetY {
    return buttonViewFinder.center.y - self.view.center.y;
}

-(float)viewFinderWidth {
    return constraintViewFinderWidth.constant;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark rotating animations
-(void)setLabelCountPosition:(int)position {
    NSLog(@"roll %lu position %d", rollCount, position);
    // 20 degrees between each number, 4 scroll wheel positions = 5 degrees each position
    float degreesCurr = 5 * position;
    float degreesPrev = degreesCurr + 20;
    float degreesNext = degreesCurr - 20;
    float degreesFuture = degreesCurr - 40;

    if (rollCount > 0)
        labelCountPrev.text = [NSString stringWithFormat:@"%lu", rollCount-1];
    else
        labelCountPrev.text = nil;
    labelCountCurr.text = [NSString stringWithFormat:@"%lu", rollCount];

    if (rollCount + 1 <= MAX_ROLL_SIZE)
        labelCountNext.text = [NSString stringWithFormat:@"%lu", rollCount+1];
    else
        labelCountNext.text = nil;

    if (rollCount + 2 <= MAX_ROLL_SIZE)
        labelCountFuture.text = [NSString stringWithFormat:@"%lu", rollCount+2];
    else
        labelCountFuture.text = nil;
    viewRotaterPrev.transform = CGAffineTransformMakeRotation(degreesPrev / 360 * 2*M_PI);
    viewRotaterCurr.transform = CGAffineTransformMakeRotation(degreesCurr / 360 * 2*M_PI);
    viewRotaterNext.transform = CGAffineTransformMakeRotation(degreesNext / 360 * 2*M_PI);
    viewRotaterFuture.transform = CGAffineTransformMakeRotation(degreesFuture / 360 * 2*M_PI);
}

-(void)imageCaptured:(NSNotification *)n {
    rollCount++;
    if (rollCount == MAX_ROLL_SIZE) {
        [buttonCapture setHidden:YES];
        [buttonRoll setHidden:NO];
        if (!isZooming)
            buttonRoll.alpha = 1;
    }

    // zoom out
    if (isZooming) {
        [self performSelector:@selector(stopLookingInViewFinder) withObject:nil afterDelay:.5];
    }
    
    if (flash) {
        [self playFlash];
        [self toggleFlash:YES];
    }

    [Appirater userDidSignificantEvent:YES];
}

#pragma mark capture button warnings
-(void)warnForAdvance {
    if (isZooming)
        return;
    
    viewGlow.alpha = .25;
    [self glow:viewGlow];
    [self performSelector:@selector(glow:) withObject:viewGlow afterDelay:.5];
    [self performSelector:@selector(glow:) withObject:viewGlow afterDelay:1];
    [self performSelector:@selector(glowHelper) withObject:nil afterDelay:1.25];

    NSString *val = [NSString stringWithFormat:@"%d", rollCount];
    [PFAnalytics trackEventInBackground:@"warnForAdvance" dimensions:@{@"rollCount": val} block:nil];
}

-(void)glowHelper {
    viewGlow.alpha = 0;
}

-(void)warnForFilm {
    [self glow:buttonRoll];
    [self performSelector:@selector(glow:) withObject:buttonRoll afterDelay:.5];
    [self performSelector:@selector(glow:) withObject:buttonRoll afterDelay:1];

    NSString *val = [NSString stringWithFormat:@"%d", rollCount];
    [PFAnalytics trackEventInBackground:@"warnForFilm" dimensions:@{@"rollCount": val} block:nil];
}

-(void)glow:(UIView *)view {
    NSLog(@"glow");
    UIColor *color = [UIColor whiteColor];
    view.layer.shadowColor = color.CGColor;
    view.layer.borderColor = color.CGColor;
    view.layer.shadowOffset = CGSizeZero;
    [UIView animateWithDuration:.5 animations:^{
        // animation doesn't work
        view.layer.shadowRadius = 5.0f;
        view.layer.shadowOpacity = 1.0f;
        [self performSelector:@selector(removeGlow:) withObject:view afterDelay:.25];
    } completion:nil];
}

-(void)removeGlow:(UIView *)view {
    NSLog(@"glow done");
    [UIView animateWithDuration:.5 animations:^{
        view.layer.shadowRadius = 0;
        view.layer.shadowOpacity = 1.0f;
    } completion:^(BOOL finished) {
        view.layer.shadowColor = [UIColor clearColor].CGColor;
    }];
}
@end
