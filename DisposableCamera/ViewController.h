//
//  ViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 12/29/14.
//  Copyright (c) 2014 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_ADVANCE_COUNT 4

@interface ViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIButton *buttonFlash;
    IBOutlet UIView *viewFilmAdvance;
    BOOL flash;
    int advancedCount;
}

-(IBAction)didClickButtonFlash:(id)sender;
-(IBAction)didClickCapture:(id)sender;
@end

