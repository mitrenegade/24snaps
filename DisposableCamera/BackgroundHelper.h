//
//  BackgroundHelper.h
//  DisposableCamera
//
//  Created by Bobby Ren on 1/25/15.
//  Copyright (c) 2015 Bobby Ren Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundHelper : NSObject

// background tasking for uploads
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) NSDecimalNumber *previous;
@property (nonatomic, strong) NSDecimalNumber *current;
@property (nonatomic) NSUInteger position;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSDate *backgroundEnterTime;

+(void)resetBackgroundTask;

+(void)keepTaskInBackgroundForPhotoUpload;
+(void)stopTaskInBackgroundForPhotoUpload;



@end
