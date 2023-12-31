//
//  FilmRollViewController.m
//  DisposableCamera
//
//  Created by Bobby Ren on 1/25/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import "FilmRollViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ios24snaps-Swift.h"
#import "Constants.h"

@interface FilmRollViewController ()

@end

@implementation FilmRollViewController

-(NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    service = [[AnalyticsService alloc] init];
    self.title = @"Film roll";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Camera Roll" style:UIBarButtonItemStyleDone target:self action:@selector(promptForDevelop)];
    }
    else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentfilm:develop:success"] boolValue]) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Film" style:UIBarButtonItemStyleDone target:self action:@selector(promptForDevelop)];
        }
        else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Develop" style:UIBarButtonItemStyleDone target:self action:@selector(promptForDevelop)];
        }
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
        NSString *title = @"Cannot save album";
        NSString *message = @"DisposableCamera could not access your camera roll. You can go to Settings->Privacy->Photos to change this.";
        [self simpleAlert:title message:message];
        [service trackEventInBackground:@"albumAccessIsDenied" block:nil];
        return;
    }
    else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        NSString *title = @"Develop your film";
        NSString *message = @"To develop your film (save it to your photo album) please give DisposableCamera access to your camera roll.";
        [UIAlertController alertViewWithTitle:title message:message cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"OK"] onDismiss:^(NSInteger buttonIndex) {
            [[ALAssetsLibrary sharedALAssetsLibrary]enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                // do nothing
            } failureBlock:nil];
            [service trackEventInBackground:@"albumRequestGranted" block:nil];
        } onCancel:^{
            [service trackEventInBackground:@"albumRequestCancelled" block:nil];

        }];
    }
    else {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"currentfilm:develop:success"] boolValue]) {
            // user has already developed this roll of film
            // allow them to reset the roll
            [UIAlertController alertViewWithTitle:@"New film?" message:@"Would you like to insert new film and start a new roll, or develop your current film roll?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"New film", @"Develop film"] onDismiss:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self resetFilm];
                }
                else {
                    [self developFilm];
                    [service trackEventInBackground:@"developClicked" dimensions:@{@"alreadyDeveloped":@"YES", @"cancelled":@"NO"} block:nil];
                }
            } onCancel:^{
                [service trackEventInBackground:@"developClicked" dimensions:@{@"alreadyDeveloped":@"YES", @"cancelled":@"YES"} block:nil];
            }];
        }
        else {
            [service trackEventInBackground:@"developClicked" dimensions:@{@"developed":@"NO"} block:nil];
            [UIAlertController alertViewWithTitle:@"Develop your film?" message:@"Would you like to develop your film (save it to your photo album) and start a new roll?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(NSInteger buttonIndex) {
                [self developFilm];
                [service trackEventInBackground:@"developClicked" dimensions:@{@"alreadyDeveloped":@"NO", @"cancelled":@"NO"} block:nil];
            } onCancel:^{
                [service trackEventInBackground:@"developClicked" dimensions:@{@"alreadyDeveloped": @"NO", @"cancelled":@"YES"} block:nil];
            }];
        }
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
    [self useAlbumName:@"DisposableCamera"];

    [service trackEventInBackground:@"developed" dimensions:@{@"defaultAlbum":@"YES"} block:nil];
}

-(void)useAlbumName:(NSString *)albumName {
    [self saveToAlbum:albumName completion:^(int failed) {
        NSString *title = @"New film";
        if (failed) {
            title = [NSString stringWithFormat:@"Save to album failed: %d", failed];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"currentfilm:develop:success"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSString *message = @"Would you like to discard this roll and insert new film?";
        NSString *cancel = @"No, save the film";
        NSString *other = @[@"New film"];
        [UIAlertController alertViewWithTitle:title message:message cancelButtonTitle:cancel otherButtonTitles:other onDismiss:^(NSInteger index) {
            [self resetFilm];
            [self rate];
        } onCancel:^{
            [self rate];
            [service trackEventInBackground:@"resetFilm" dimensions:@{@"cancelled":@"YES"} block:nil];
        }];
    }];
}

-(void)resetFilm {
    NSLog(@"Reset film");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentfilm:develop:success"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.delegate resetImages];
    [service trackEventInBackground:@"resetFilm" dimensions:@{@"cancelled":@"NO"} block:nil];
}

-(void)saveToAlbum:(NSString *)albumName completion:(void(^)(int failed))completion {
    // save to album

    NSLog(@"Saving to album: %@", albumName);
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self saveToAlbumHelper:self.images albumName:albumName failedCount:0 completion:completion];
}

-(void)saveToAlbumHelper:(NSArray *)imagesLeft albumName:(NSString *)albumName failedCount:(int)failed completion:(void(^)(int failed))completion {
    if ([imagesLeft count] == 0) {
        // won't come here
        completion(failed);
        return;
    }

    UIImage *currentImage = [imagesLeft firstObject];
    NSMutableArray *imagesLeftNow = [imagesLeft mutableCopy];
    [imagesLeftNow removeObject:currentImage];
    NSLog(@"Images left in queue: %d", [imagesLeftNow count]);
    progress.labelText = [NSString stringWithFormat:@"Developing %d of %d", MAX_ROLL_SIZE - imagesLeftNow.count, MAX_ROLL_SIZE];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:[self makeImageNegative:currentImage] meta:nil toAlbum:albumName withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Image could not be saved! error: %@", error);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if([imagesLeftNow count] == 0) {
                        completion(failed+1);
                        [progress hide:YES];
                    }
                    else {
                        [self saveToAlbumHelper:imagesLeftNow albumName:albumName failedCount:failed completion:completion];
                    }
                });
            }
            else {
                NSLog(@"Saved to album");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if([imagesLeftNow count] == 0) {
                        completion(failed);
                        [progress hide:YES];
                    }
                    else {
                        [self saveToAlbumHelper:imagesLeftNow albumName:albumName failedCount:failed completion:completion];
                    }
                });
            }
        }];
    });
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [alertAlbumName dismissWithClickedButtonIndex:0 animated:YES];

    NSString *title = [alertAlbumName textFieldAtIndex:0].text;
    [self useAlbumName:title];

    [service trackEventInBackground:@"developed" dimensions:@{@"defaultAlbum":@"NO"} block:nil];
    return YES;
}

- (UIImage *)makeImageNegative:(UIImage *)image{
    UIGraphicsBeginImageContext(image.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor       whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0,   image.size.width, image.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

-(void)rate {
    // force app rating
    NSLog(@"TODO");
}

@end
