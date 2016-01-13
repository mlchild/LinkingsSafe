//
//  NSString+ValidURL.m
//  GramCracker
//
//  Created by Max Child on 8/16/15.
//  Copyright (c) 2015 Volley Inc. All rights reserved.
//

#import "NSString+ValidURL.h"

@implementation NSString (ValidURL)

- (BOOL)isValidURL {
    NSUInteger length = [self length];
    // Empty strings should return NO
    if (length > 0) {
        NSError *error = nil;
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:self options:0 range:range];
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                return YES;
            }
        }
        else {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    return NO;
}

@end
