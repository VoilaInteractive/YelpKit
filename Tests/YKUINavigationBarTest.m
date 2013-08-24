//
//  YKUINavigationBarTest.m
//  YelpKit
//
//  Created by Alexander Haefner on 7/30/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

#import <QuartzCore/CoreAnimation.h>
#import "YKUINavigationBarTest.h"
#import "YKUINavigationBar.h"
#import "YKUIButton.h"

@implementation YKUINavigationBarTest

- (void)testNavigationBar {
  UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44 * 4)];
  
  YKUINavigationBar *navBar1 = [[YKUINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  YKUINavigationBar *navBar2 = [[YKUINavigationBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
  YKUINavigationBar *navBar3 = [[YKUINavigationBar alloc] initWithFrame:CGRectMake(0, 88, 320, 44)];
  YKUINavigationBar *navBar4 = [[YKUINavigationBar alloc] initWithFrame:CGRectMake(0, 132, 320, 44)];
  for (YKUINavigationBar *navBar in @[navBar1, navBar2, navBar3, navBar4]) {
    [superView addSubview:navBar];
  }

  YKUIButton *leftButton1 = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32) title:@"Left" target:nil action:nil];
  YKUIButton *rightButton1 = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32) title:@"Right" target:nil action:nil];
  YKUIButton *leftButton2 = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32) title:@"Left" target:nil action:nil];
  YKUIButton *rightButton2 = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32) title:@"Right" target:nil action:nil];
  YKUIButton *leftButton3 = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32) title:@"Left" target:nil action:nil];
  YKUIButton *rightButton3 = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32) title:@"Right" target:nil action:nil];

  [navBar1 setLeftButton:leftButton1 style:YKUINavigationButtonStyleBack animated:NO];
  [navBar2 setRightButton:rightButton1 style:YKUINavigationButtonStyleDone animated:NO];
  [navBar3 setRightButton:rightButton2];
  [navBar3 setLeftButton:leftButton2];
  [navBar3 setTitle:@"TestNavBar" animated:NO];
  [navBar4 setLeftButton:leftButton3];
  [navBar4 setRightButton:rightButton3];
  [navBar4 setTitle:@"SuperLongTitle That will overflow and be wrapped" animated:NO];
  GHVerifyView(superView);
  
  for (YKUIButton *button in @[leftButton1, leftButton2, leftButton3, rightButton1, rightButton2, rightButton3]) {
    [button release];
  }
  
  for (YKUINavigationBar *navBar in @[navBar1, navBar2, navBar3, navBar4]) {
    [navBar release];
  }
  [superView release];
}

- (void)testAnimatedNavBar {
  UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44 * 4)];
  
  YKUINavigationBar *navBar1 = [[YKUINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  YKUINavigationBar *navBar2 = [[YKUINavigationBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
  [superView addSubview:navBar1];
  [superView addSubview:navBar2];
  [navBar1 release];
  [navBar2 release];
  [navBar1 setTitle:@"SomeTitle" animated:NO];
  [navBar2 setTitle:@"SomeTitle" animated:NO];
  [navBar2 setTitle:@"SomeNewTitlte" animated:YES];
  GHRunForInterval(kYKUINavigationBarTitelAnimationDuration + 0.02);
  GHVerifyView(superView);
  [superView release];
}

@end
