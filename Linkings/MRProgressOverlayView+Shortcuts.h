//
//  MRProgressOverlayView+Shortcuts.h
//  Detail
//
//  Created by Max Child on 12/19/13.
//  Copyright (c) 2013 Max Child. All rights reserved.
//

#import "MRProgressOverlayView.h"

@interface MRProgressOverlayView (Shortcuts)

+ (UIView *)sharedView;

+ (void)showSuccessWithStatus:(NSString *)status;
+ (void)showSuccessWithStatus:(NSString *)status inView:(UIView *)view;
+ (void)showSuccessWithStatus:(NSString *)status inView:(UIView *)view afterDelay:(NSTimeInterval)startDelay;
+ (void)showSuccessWithStatus:(NSString *)status
                       inView:(UIView *)view
                   afterDelay:(NSTimeInterval)startDelay
            dismissAfterDelay:(NSTimeInterval)dismissDelay;


+ (void)showErrorWithStatus:(NSString *)status;
+ (void)showErrorWithStatus:(NSString *)status inView:(UIView *)view;
+ (void)showErrorWithStatus:(NSString *)status inView:(UIView *)view afterDelay:(NSTimeInterval)startDelay;
+ (void)showErrorWithStatus:(NSString *)status
                     inView:(UIView *)view
                 afterDelay:(NSTimeInterval)startDelay
          dismissAfterDelay:(NSTimeInterval)dismissDelay;

@end
