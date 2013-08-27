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

  UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:nil action:nil];
  UIBarButtonItem *leftButton2 = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:nil action:nil];
  UIBarButtonItem *leftButton3 = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:nil action:nil];
  UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:nil action:nil];
  UIBarButtonItem *rightButton2 = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:nil action:nil];
  UIBarButtonItem *rightButton3 = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:nil action:nil];

  navBar1.navigationItem.leftBarButtonItem = leftButton1;
  navBar2.navigationItem.rightBarButtonItem = rightButton1;
  navBar3.navigationItem.rightBarButtonItem = rightButton2;
  navBar3.navigationItem.leftBarButtonItem = leftButton2;
  [navBar3 setTitle:@"TestNavBar" animated:NO];
  navBar4.navigationItem.leftBarButtonItem = leftButton3;
  navBar4.navigationItem.rightBarButtonItem = rightButton3;
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
