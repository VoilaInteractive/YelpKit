//
//  YKUISwitchButton.m
//  YelpKit
//
//  Created by Gabriel Handford on 6/26/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKUISwitchButton.h"

@implementation YKUISwitchButton

@synthesize button=_button, switchControl=_switchControl;

- (void)sharedInit {
  [super sharedInit];
  self.layout = [YKLayout layoutForView:self];
  self.backgroundColor = [UIColor clearColor];

  _button = [[YKUIButton alloc] init];
  [self addSubview:_button];
  [_button release];
  
  _switchControl = [[UISwitch alloc] init];
  [_switchControl addTarget:self action:@selector(_switchChanged) forControlEvents:UIControlEventValueChanged];
  [self addSubview:_switchControl];
  [_switchControl release];
  
  _button.titleInsets = UIEdgeInsetsMake(10, 10, 10, _switchControl.frame.size.width - 10);
  _button.titleAlignment = NSTextAlignmentLeft;
  _button.targetDisabled = YES;
  [_button addTarget:self action:@selector(_didTouchUpInside)];
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  [layout setFrame:CGRectMake(0, 0, size.width, size.height) view:_button];
  CGFloat x = size.width - _switchControl.frame.size.width - 10;
  if (x < 0) x = 0;
  CGFloat y = roundf(size.height/2.0f - _switchControl.frame.size.height/2.0f);
  if (y < 0) y = 0;
  [layout setOrigin:CGPointMake(x, y) view:_switchControl];
  return size;
}

- (void)_switchChanged {
  [_button callTarget];
}

- (void)_didTouchUpInside {
  [_switchControl setOn:!_switchControl.on animated:YES];
  [_button callTarget];
}

@end
