//
//  YKCatalogViewStack.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/2/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKCatalogViewStack.h"
#import "YKCatalogTestView.h"

@implementation YKCatalogViewStack

- (void)sharedInit {
  [super sharedInit];

  _tableView = [[[YKTableView alloc] init] autorelease];
  [self setView:_tableView];
  [self.navigationItem setTitle:@"View Stack"];
  
  __block id blockSelf = self;
  
  [self addActionWithTitle:@"Slide Over" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlideOver];
  }];
  
  [self addActionWithTitle:@"Slide" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlide];
  }];
  
  [self addActionWithTitle:@"Curl Up" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionCurlUp];
  }];
  
  [self addActionWithTitle:@"Curl Down" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionCurlDown];
  }];
  
  [self addActionWithTitle:@"Flip From Left" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionFlipFromLeft];
  }];
  
  [self addActionWithTitle:@"Flip From Right" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionFlipFromRight];
  }];
  
  [self addActionWithTitle:@"Cross Dissolve" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionCrossDissolve];
  }];
  
  [self addActionWithTitle:@"Flip From Top" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionFlipFromTop];
  }];
  
  [self addActionWithTitle:@"Flip From Bottom" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackView] duration:1.0 options:YKSUIViewAnimationOptionTransitionFlipFromBottom];
  }];

  [self addActionWithTitle:@"Multi Push (Slide Over)" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackViewWithName:@"View 1"] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlideOver];
    [blockSelf pushView:[YKCatalogTestView testStackViewWithName:@"View 2"] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlideOver];
  }];

  [self addActionWithTitle:@"Multi Push (Slide)" targetBlock:^() {
    [blockSelf pushView:[YKCatalogTestView testStackViewWithName:@"View 1"] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlide];
    [blockSelf pushView:[YKCatalogTestView testStackViewWithName:@"View 2"] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlide];
  }];

  [self addActionWithTitle:@"" targetBlock:^() {
    
  }];
}

- (void)addActionWithTitle:(NSString *)title targetBlock:(UIControlTargetBlock)targetBlock {
  YKUIButtonCell *cell = [[[YKUIButtonCell alloc] init] autorelease];
  cell.button.title = title;
  cell.button.targetBlock = targetBlock;
  [_tableView.dataSource addCellDataSource:cell section:0];
}

@end
