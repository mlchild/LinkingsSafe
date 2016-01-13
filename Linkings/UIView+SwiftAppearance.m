//
//  UIView+SwiftAppearance.m
//  GramCracker
//
//  Created by Max Child on 8/30/15.
//  Copyright (c) 2015 Volley Inc. All rights reserved.
//

#import "UIView+SwiftAppearance.h"

@implementation UIView (SwiftAppearance)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedInInstancesOfClasses:@[containerClass]];
}
@end

@implementation UIBarItem (SwiftAppearance)

+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedInInstancesOfClasses:@[containerClass]];
}
@end