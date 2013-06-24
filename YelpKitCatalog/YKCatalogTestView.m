//
//  YKCatalogTestView.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/2/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKCatalogTestView.h"

@implementation YKCatalogTestView

- (void)sharedInit {
  [super sharedInit];
  self.layout = [YKLayout layoutForView:self];
  self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
  _button = [[YKUIButton alloc] init];
  _button.titleFont = [UIFont boldSystemFontOfSize:32];
  _button.titleAlignment = NSTextAlignmentCenter;
  _button.borderColor = [UIColor grayColor];
  _button.borderWidth = 5.0;
  _button.borderStyle = YKUIBorderStyleNormal;
  _button.backgroundColor = [UIColor clearColor];
  [self addSubview:_button];
  [_button autorelease];
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  [layout setFrame:CGRectMake(20, 20, size.width - 40, size.height - 40) view:_button options:YKLayoutOptionsCenterVertical];
  return size;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"YKCatalogTestView; %@", _button.title];
}

+ (YKSUIView *)testStackView {
  return [self testStackViewWithName:@"Test View"];
}

+ (YKSUIView *)testStackViewWithName:(NSString *)name {
  YKCatalogTestView *testView = [[[YKCatalogTestView alloc] init] autorelease];
  testView->_button.title = name;
  YKSUIView *stackView = [YKSUIView viewWithView:testView];
  [stackView.navigationBar setTitle:name animated:NO];
  return stackView;
}

@end
