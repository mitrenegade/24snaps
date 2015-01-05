//
//  ViewController.m
//  DisposableCamera
//
//  Created by Bobby Ren on 12/29/14.
//  Copyright (c) 2014 Bobby Ren Tech. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    AVAudioPlayer *playerFlash;
    AVAudioPlayer *playerClickFlash;
    AVAudioPlayer *playerClick;
    AVAudioPlayer *playerAdvance;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [swipe setDelegate:self];
    [self.view addGestureRecognizer:swipe];

    advancedCount = 6;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
@end
