//
//  UIView+SwiftAppearance.h
//  GramCracker
//
//  Created by Max Child on 8/30/15.
//  Copyright (c) 2015 Volley Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SwiftAppearance)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end

@interface UIBarItem (SwiftAppearance)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
