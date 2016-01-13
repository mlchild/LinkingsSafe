//
//  MRProgressOverlayView+Shortcuts.m
//  Detail
//
//  Created by Max Child on 12/19/13.
//  Copyright (c) 2013 Max Child. All rights reserved.
//

#import "MRProgressOverlayView+Shortcuts.h"
//#import "UIColor+Veritas.h"

@implementation MRProgressOverlayView (Shortcuts)

+ (UIView *)sharedView {
    static dispatch_once_t once;
    static UIView *sharedView;
    dispatch_once(&once, ^ { sharedView = [UIApplication sharedApplication].keyWindow; });
    return sharedView;
}

+ (void)showSuccessWithStatus:(NSString *)status inView:(UIView *)view afterDelay:(NSTimeInterval)startDelay dismissAfterDelay:(NSTimeInterval)dismissDelay {
    [self performBlock:^{
        
        NSArray *overlays = [self allOverlaysForView:[self sharedView]];
        if (overlays.count > 0) { NSLog(@"already showing mrprogressview"); return; }
        
        MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:view ?: [self sharedView] animated:YES];
        progressView.mode = MRProgressOverlayViewModeCheckmark;
        progressView.titleLabelText = status;
        
        [self performBlock:^{
            [progressView dismiss:YES];
        } afterDelay:dismissDelay];
        
    } afterDelay:startDelay];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    [self showSuccessWithStatus:status inView:nil];
}

+ (void)showSuccessWithStatus:(NSString *)status inView:(UIView *)view {
    [self showSuccessWithStatus:status inView:view afterDelay:0.0f dismissAfterDelay:2.0];
}

+ (void)showSuccessWithStatus:(NSString *)status inView:(UIView *)view afterDelay:(NSTimeInterval)startDelay {
    [self showSuccessWithStatus:status inView:view afterDelay:startDelay dismissAfterDelay:2.0];
}


+ (void)showErrorWithStatus:(NSString *)status {
    [self showErrorWithStatus:status inView:nil];
}

+ (void)showErrorWithStatus:(NSString *)status inView:(UIView *)view {
    [self showErrorWithStatus:status inView:view afterDelay:0.0f dismissAfterDelay:2.0f];
}

+ (void)showErrorWithStatus:(NSString *)status inView:(UIView *)view afterDelay:(NSTimeInterval)startDelay {
    [self showErrorWithStatus:status inView:view afterDelay:startDelay dismissAfterDelay:2.0f];
}

+ (void)showErrorWithStatus:(NSString *)status inView:(UIView *)view afterDelay:(NSTimeInterval)startDelay dismissAfterDelay:(NSTimeInterval)dismissDelay {
    
    [self performBlock:^{
        NSArray *overlays = [self allOverlaysForView:[self sharedView]];
        if (overlays.count > 0) { NSLog(@"already showing mrprogressview"); return; }
        
        MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:view ?: [self sharedView] animated:YES];
        progressView.mode = MRProgressOverlayViewModeCross;
        progressView.titleLabelText = status;
//        progressView.tintColor = [UIColor red1976];
        [self performBlock:^{
            [progressView dismiss:YES];
        } afterDelay:dismissDelay];
    
    } afterDelay:startDelay];
}


+ (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
