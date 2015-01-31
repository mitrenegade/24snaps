//
//  FilmRollViewController.m
//  DisposableCamera
//
//  Created by Bobby Ren on 1/25/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import "FilmRollViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface FilmRollViewController ()

@end

@implementation FilmRollViewController

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Film roll";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Camera Roll" style:UIBarButtonItemStyleDone target:self action:@selector(promptForDevelop)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Develop" style:UIBarButtonItemStyleDone target:self action:@selector(promptForDevelop)];
    }

    self.navigationController.delegate = self;
    // todo: set landscape mode only for this controller
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * self.images.count, scrollView.frame.size.height);
    for (int i=0; i<self.images.count; i++) {
        UIImage *image = self.images[i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(scrollView.frame.size.width * i, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
    }
}

-(void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)promptForDevelop {
    // check for album
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
        [UIAlertView alertViewWithTitle:@"Cannot save album" message:@"DisposableCamera could not access your camera roll. You can go to Settings->Privacy->Photos to change this."];
        return;
    }
    else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        [UIAlertView alertViewWithTitle:@"Develop your film" message:@"To develop your film (save it to your photo album) please give DisposableCamera access to your camera roll." cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex) {
            [[ALAssetsLibrary sharedALAssetsLibrary]enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                // do nothing
            } failureBlock:nil];
        } onCancel:nil];
    }
    else {
        [UIAlertView alertViewWithTitle:@"Develop your film?" message:@"Would you like to develop your film (save it to your photo album) and start a new roll?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex) {
            [self developFilm];
        } onCancel:nil];
    }
}

#pragma mark Albums
-(void)developFilm {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter an album name" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

    UITextField *textField = [alert textFieldAtIndex:0];
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAlbum:)];
    UIBarButtonItem *defaultButton = [[UIBarButtonItem alloc] initWithTitle:@"Default Album" style:UIBarButtonItemStyleBordered target:self action:@selector(defaultAlbum:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [keyboardDoneButtonView setItems:@[cancel, flex, defaultButton]];
    textField.inputAccessoryView = keyboardDoneButtonView;
    textField.returnKeyType = UIReturnKeyGo;
    textField.delegate = self;

    alertAlbumName = alert;
    [alert show];
}

-(void)cancelAlbum:(id)sender {
    [self.view endEditing:YES];
    [alertAlbumName dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)defaultAlbum:(id)sender {
    [self.view endEditing:YES];
    [alertAlbumName dismissWithClickedButtonIndex:0 animated:YES];

    // default name
    [self saveToAlbum:@"DisposableCamera"];
}

-(BOOL)saveToAlbum:(NSString *)albumName {
    // save to album

    NSLog(@"Saving to album: %@", albumName);
/*
    NSMutableDictionary *cachedMeta = [meta mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:image meta:cachedMeta toAlbum:@"babyGems" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Image could not be saved!");
            }
            else {
                NSLog(@"Saved to album with meta: %@", cachedMeta);
            }
        }];
    });

 */
    return YES;
}

#pragma mark UITextFieldDelegate 
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [alertAlbumName dismissWithClickedButtonIndex:0 animated:YES];

    NSString *title = [alertAlbumName textFieldAtIndex:0].text;
    [self saveToAlbum:title];
    return YES;
}
@end
