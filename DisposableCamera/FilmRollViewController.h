//
//  FilmRollViewController.h
//  DisposableCamera
//
//  Created by Bobby Ren on 1/25/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilmRollDelegate <NSObject>

-(void)resetImages;

@end

@interface FilmRollViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet __weak UIAlertView *alertAlbumName;
}

@property (weak, nonatomic) NSArray *images;
@property (weak, nonatomic) id delegate;
@end
