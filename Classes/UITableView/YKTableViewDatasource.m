//
//  YKTableViewDataSource.m
//  YelpKit
//
//  Created by Gabriel Handford on 5/13/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "YKTableViewDataSource.h"

@implementation YKTableViewDataSource

@synthesize sectionIndexTitles=_sectionIndexTitles, sectionHeaderViewBlock=_sectionHeaderViewBlock, sectionFooterViewBlock=_sectionFooterViewBlock, tableViewDidScrollToBottomBlock=_tableViewDidScrollToBottomBlock, scrollViewDelegate=_scrollViewDelegate;

- (id)init {
  if ((self = [super init])) {
    _sectionCount = 1;
  }
  return self;
}

- (id)initWithSectionCount:(NSInteger)sectionCount {
  NSParameterAssert(sectionCount > 0);
  if ((self = [self init])) {
    _sectionCount = sectionCount;
  }
  return self;
}

- (void)dealloc {
  [_cellDataSourceSections release];
  [_sectionHeaderTitles release];
  Block_release(_sectionHeaderViewBlock);
  Block_release(_tableViewDidScrollToBottomBlock);
  [super dealloc];
}

+ (YKTableViewDataSource *)dataSource {
  return [[[self alloc] init] autorelease];
}

+ (YKTableViewDataSource *)dataSourceWithCellDataSources:(NSArray */*of id<YKTableViewCellDataSource>*/)cellDataSources {
  YKTableViewDataSource *dataSource = [self dataSource];
  [dataSource addCellDataSources:cellDataSources section:0 indexPaths:nil];
  return dataSource;
}

- (void)clearAll {
  [_cellDataSourceSections release];
  _cellDataSourceSections = nil;
}

- (void)clearHeaders {
  [_sectionHeaderTitles release];
  _sectionHeaderTitles = nil;
}

- (NSMutableArray *)dataSourceForSection:(NSInteger)section create:(BOOL)create {
  if (!_cellDataSourceSections && create) _cellDataSourceSections = [[NSMutableDictionary alloc] init];
  
  NSMutableArray *dataSource = _cellDataSourceSections[@(section)];
  if (create && !dataSource) {
    dataSource = [NSMutableArray array];
    _cellDataSourceSections[@(section)] = dataSource;
  }
  return dataSource;
}

- (NSMutableArray *)cellDataSourcesForSection:(NSInteger)section {
  return _cellDataSourceSections[@(section)];
}

- (NSMutableArray *)dataSourceForSection:(NSInteger)section {
  return [self dataSourceForSection:section create:NO];
}

- (NSInteger)countForSection:(NSInteger)section {
  return [[self dataSourceForSection:section] count];
}

- (id<YKTableViewCellDataSource>)cellDataSourceAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableArray *dataSource = [self dataSourceForSection:indexPath.section];
  if (dataSource && indexPath.row < [dataSource count])
    return dataSource[indexPath.row];
  return nil;
}

- (NSIndexPath *)indexPathForCellDataSource:(id<YKTableViewCellDataSource>)cellDataSource {
  for (NSInteger section = 0; section < _sectionCount; section++) {
    NSArray *cellDataSources = [self dataSourceForSection:section create:NO];
    NSInteger row = 0;
    for (id cellDataSourceCheck in cellDataSources) {
      if ([cellDataSource isEqual:cellDataSourceCheck]) return [NSIndexPath indexPathForRow:row inSection:section];
      row++;
    }
  }
  return nil;
}

- (BOOL)removeCellDataSourceAtIndexPath:(NSIndexPath *)indexPath {
  if (!indexPath) {
    return NO;
  }
  return [self removeCellDataSourceForRow:indexPath.row inSection:indexPath.section];
}

- (BOOL)removeCellDataSourceForRow:(NSInteger)row inSection:(NSInteger)section {
  NSMutableArray *dataSource = [self dataSourceForSection:section];
  if (row < [dataSource count]) {
    [dataSource removeObjectAtIndex:row];
    return YES;
  }
  return NO;
}

- (void)removeCellDataSourceAtIndexPaths:(NSArray *)indexPaths {
  for (NSIndexPath *indexPath in indexPaths) {
    [self removeCellDataSourceForRow:indexPath.row inSection:indexPath.section];
  }
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  id<YKTableViewCellDataSource> cellDataSource = [self cellDataSourceAtIndexPath:indexPath];
  UITableViewCell *cell = [cellDataSource cellForTableView:tableView rowAtIndexPath:indexPath];
  return cell;
}

- (NSEnumerator *)enumeratorForCellDataSources {
  return [[[YKTableViewDataSourceEnumerator alloc] initWithDataSource:self] autorelease];
}

- (void)insertCellDataSources:(NSArray */*of id<YKTableViewCellDataSource>*/)array section:(NSInteger)section atIndex:(NSInteger)index indexPaths:(NSMutableArray **)indexPaths { 
  NSMutableArray *dataSource = [self dataSourceForSection:section create:YES];
  
  NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
  for(NSInteger i = 0; i < [array count]; i++) {
    [indexes addIndex:(i + index)];
    if (indexPaths) [*indexPaths addObject:[NSIndexPath indexPathForRow:(i + index) inSection:section]];
  }
  
  [dataSource insertObjects:array atIndexes:indexes];
  if (section >= _sectionCount) _sectionCount = section + 1;
}

- (void)insertCellDataSource:(id<YKTableViewCellDataSource>)cellDataSource atIndexPath:(NSIndexPath *)indexPath {
  NSMutableArray *dataSource = [self dataSourceForSection:indexPath.section create:YES];
  [dataSource insertObject:cellDataSource atIndex:indexPath.row];
}

- (NSIndexPath *)addCellDataSource:(id<YKTableViewCellDataSource>)cellDataSource section:(NSInteger)section {
  NSMutableArray *dataSource = [self dataSourceForSection:section create:YES];
  NSInteger previousCount = [dataSource count];
  [dataSource addObject:cellDataSource];
  if (section >= _sectionCount) _sectionCount = section + 1;
  return [NSIndexPath indexPathForRow:previousCount inSection:section];
}

- (void)addCellDataSources:(NSArray */*of id<YKTableViewCellDataSource>*/)array section:(NSInteger)section indexPaths:(NSMutableArray **)indexPaths {
  NSMutableArray *dataSource = [self dataSourceForSection:section create:YES];
  NSInteger previousCount = [dataSource count];
  [dataSource addObjectsFromArray:array];
  if (section >= _sectionCount) _sectionCount = section + 1;
  
  if (indexPaths) {
    for(NSInteger i = 0, count = [array count]; i < count; i++) {
      [*indexPaths addObject:[NSIndexPath indexPathForRow:(i + previousCount) inSection:section]];
    }
  }
}

- (BOOL)hasSectionBefore:(NSInteger)section {
  for (NSInteger i = 0, sectionCount = [self sectionCount]; i < section && i < sectionCount; i++) {
    if ([self countForSection:i] > 0) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)isOnlySection:(NSInteger)section {
  BOOL hasDataForOtherSections = NO;
  for (NSInteger i = 0; i < [self sectionCount]; i++) {
    if (i == section) continue;
    if ([self countForSection:i] > 0) {
      hasDataForOtherSections = YES;
      break;
    }
  }
  return !hasDataForOtherSections;
}

- (void)truncateCellDataSourcesToCount:(NSInteger)count section:(NSInteger)section indexPaths:(NSMutableArray **)indexPaths {
  NSMutableArray *dataSource = [self dataSourceForSection:section];
  NSInteger cellCount = [dataSource count];
  if (cellCount <= count) return;
  [dataSource removeObjectsInRange:NSMakeRange(count, cellCount - count)];
  
  if (indexPaths) {
    for(NSInteger i = count; i < cellCount; i++) {
      [*indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
  }
}

- (void)replaceCellDataSource:(id<YKTableViewCellDataSource>)cellDataSource indexPath:(NSIndexPath *)indexPath {
  NSMutableArray *dataSource = [self dataSourceForSection:indexPath.section];
  if (indexPath.row < [dataSource count]) {
    dataSource[indexPath.row] = cellDataSource;
  }
}

- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
  id<YKTableViewCellDataSource> cellDataSource = [[self cellDataSourceAtIndexPath:fromIndexPath] retain];
  [self removeCellDataSourceAtIndexPath:fromIndexPath];
  [self insertCellDataSource:cellDataSource atIndexPath:toIndexPath];
  [cellDataSource release];
}

- (void)setCellDataSources:(NSArray */*of id<YKTableViewCellDataSource>*/)array section:(NSInteger)section {
  NSMutableArray *dataSource = [self dataSourceForSection:section create:YES];
  [dataSource setArray:array];
  if (section >= _sectionCount) _sectionCount = section + 1;
}

- (NSMutableDictionary *)_sectionHeaderTitles {
  if (!_sectionHeaderTitles) _sectionHeaderTitles = [[NSMutableDictionary alloc] init];
  return _sectionHeaderTitles;
}

- (void)setSectionHeaderTitle:(NSString *)title section:(NSInteger)section {
  if (title) {
    [self _sectionHeaderTitles][@(section)] = title;
  } else {
    [_sectionHeaderTitles removeObjectForKey:@(section)];
  }
}

- (void)setSectionHeaderTitles:(NSArray *)titles {
  NSInteger i = 0;
  for (NSString *title in titles) {
    [self _sectionHeaderTitles][@(i++)] = title;
  }
}

- (BOOL)hasSectionHeaderTitleForSection:(NSInteger)section {
  if ([self countForSection:section] > 0) 
    return (_sectionHeaderTitles[@(section)] != nil);
  return NO;  
}

- (void)clearSection:(NSInteger)section indexPaths:(NSMutableArray **)indexPaths {
  NSMutableArray *dataSource = [self dataSourceForSection:section];
  if (indexPaths) {
    for(NSInteger i = 0; i < [dataSource count]; i++) {
      [*indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
  }
  [dataSource removeAllObjects];
}

- (NSInteger)count {
  NSInteger count = 0;
  for(NSInteger i = 0; i < _sectionCount; i++) {
    count += [self countForSection:i];
  }
  return count;
}

- (NSInteger)sectionCount {
  return _sectionCount;
}

- (NSIndexPath *)lastIndexPath {
  NSInteger sectionIndex = [self sectionCount] - 1;
  while(sectionIndex >= 0) {
    NSInteger rowIndex = [self countForSection:sectionIndex] - 1;
    if (rowIndex >= 0) {
      return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    }
    sectionIndex--;
  }
  return nil;
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self cellForTableView:tableView indexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self dataSourceForSection:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  id<YKTableViewCellDataSource> cellDataSource = [self cellDataSourceAtIndexPath:indexPath];
  return [cellDataSource sizeThatFits:CGSizeMake(tableView.frame.size.width, tableView.frame.size.height)].height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return _sectionHeaderTitles[@(section)];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  // Only show view if we have cells
  //if ([self countForSection:section] == 0) return nil;
  
  NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];

  if (!_sectionHeaderViewBlock) return nil;
  
  NSInteger rowCount = [self tableView:tableView numberOfRowsInSection:section];
  return _sectionHeaderViewBlock(section, sectionTitle, rowCount);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  UIView *sectionHeaderView = [self tableView:tableView viewForHeaderInSection:section];
  if (sectionHeaderView) {
    CGFloat height = sectionHeaderView.frame.size.height;
    if (height == 0) height = 24.0f; // Return a sane default, so we can at least debug
    return height;
  }
  return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if (!_sectionFooterViewBlock) return nil;
  NSInteger rowCount = [self tableView:tableView numberOfRowsInSection:section];
  return _sectionFooterViewBlock(section, rowCount);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return [self tableView:tableView viewForFooterInSection:section].frame.size.height;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return _sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	if (title == UITableViewIndexSearch) {
		// Hack to scroll to table header if selecting the UITableViewIndexSearch item
		[tableView setContentOffset:CGPointZero];
		return -1;
	}
	return index;
}

#pragma mark YKTableScrollViewDelegate/UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
    [_scrollViewDelegate scrollViewDidScroll:scrollView];
  }
  
  // Only notify once per scrollViewDidEndDecelerating: cycle
  if (_scrollDidNotify) return;
  // Notify the delegate 100 px before actually reaching the bottom of the scrollview
  if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height - 100)) {
    _scrollDidNotify = YES;
    if (_tableViewDidScrollToBottomBlock != NULL) _tableViewDidScrollToBottomBlock(self);
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
    [_scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
  }
  _scrollDidNotify = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
    [_scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  }
}

@end


@implementation YKTableViewDataSourceEnumerator 

- (id)initWithDataSource:(YKTableViewDataSource *)dataSource {
  if ((self = [super init])) {
    _dataSource = [dataSource retain];
    _section = 0;
    _index = 0;
  }
  return self;
}

- (void)dealloc {
  [_dataSource release];
  [super dealloc];
}

- (id)nextObject {
  if (_section >= [_dataSource sectionCount]) return nil;
  NSArray *cellDataSources = [_dataSource cellDataSourcesForSection:_section];
  if (_index >= [cellDataSources count]) {
    _index = 0;
    _section++;
    return [self nextObject];
  }
  return cellDataSources[_index++];
}

- (NSIndexPath *)indexPath {
  return [NSIndexPath indexPathForRow:_index inSection:_section];
}

@end
