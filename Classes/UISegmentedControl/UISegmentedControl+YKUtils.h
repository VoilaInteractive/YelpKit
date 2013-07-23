//
//  UISegmentedControl+YKUtils.h
//  YelpKit
//
//  Created by Alexander Haefner on 7/22/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (YKUtils)

- (NSUInteger)indexForTitle:(NSString *)title;

@end
