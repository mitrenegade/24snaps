//
//  UIImagePickerController+Landscape.m
//  DisposableCamera
//
//  Created by Bobby Ren on 1/5/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import "UIImagePickerController+Landscape.h"

@implementation UIImagePickerController (Landscape)

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

@end
