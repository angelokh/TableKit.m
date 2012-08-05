//
// Created by Bruno Wernimont on 2012
// Copyright 2012 TableKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

#import "TKBlocks.h"

@class TKCellMapping;

@interface TKTableModel : NSObject <UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary *_objectMappings;
    dispatch_queue_t _concurrentQueue;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) TKObjectForRowAtIndexPathBlock objectForRowAtIndexPathBlock;
@property (nonatomic, copy) TKScrollViewScrollBlock onScrollWithBlock;

@property (nonatomic, readonly) NSMutableDictionary *objectMappings;

/**
 This is used to forward UITableViewDelegate, UITableViewDataSource and UIScrollViewDelegate unimplemend by TKTableModel.
 */
@property (nonatomic, weak) id delegate;

/**
 Short method to create a tableModel
 @param tableView The tableView that will be used to show cell
 */
+ (id)tableModelForTableView:(UITableView *)tableView;

/**
 Create a tableModel
 @param tableView The tableView that will be used to show cell
 */
- (id)initWithTableView:(UITableView *)tableView;

/**
 Add cell mapping to the model
 @param cellMapping Instance of cellMapping
 */
- (void)registerMapping:(TKCellMapping *)cellMapping;

/**
 Inform the model that a row has been selected
 @param indexPath IndexPath of the selected row
 */
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Inform the model that a row has been selected
 @param tableView tableView from object that you want
 @param indexPath IndexPath of the selected row
 */
- (void)didSelectRowAtTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

/**
 Return the height of the object with indexPath
 @param object Object of row
 @param indexPath IndexPath of row
 */
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath;

/**
 Block that must return an object for the given indexPath
 @param block Block that return a model for the given indexPath
 */
- (void)objectForRowAtIndexPathWithBlock:(TKObjectForRowAtIndexPathBlock)block;

/**
 Called when the row is scrolled
 */
- (void)onScrollWithBlock:(TKScrollViewScrollBlock)onScrollWithBlock;

/**
 Return object at indexPath
 @param indexPath IndexPath from object that you want
 */
- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Return object at tableView with indexPath
 @param tableView tableView from object that you want
 @param indexPath IndexPath from object that you want
 */
- (id)objectForRowAtTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath;

/**
 Return a cell for a given object
 @param object Object to map
 */
- (UITableViewCell *)mapCellForObject:(id)object;

/**
 Reload items
 */
- (void)loadItems;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource Helper

/**
 Return a cell at given indexPath
 @param indexPath IndexPath from cell that you want
 */
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Return a cell at given indexPath
 @param tableView tableView from object that you want
 @param indexPath IndexPath from cell that you want
 */
- (UITableViewCell *)cellForRowAtTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath;

/**
 Return the height of the row
 @param indexPath IndexPath of row
 */
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Return the height of the row
 @param tableView tableView from object that you want
 @param indexPath IndexPath of row
 */
- (CGFloat)heightForRowAtTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath;

/**
 Inform model that the cell will be displayed
 @param cell Cell that will be displayed
 @param indexPath indexPath of the cell that will be displayed
 */
- (void)willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Inform model that the cell will be displayed
 @param tableView tableView from object that you want
 @param cell Cell that will be displayed
 @param indexPath indexPath of the cell that will be displayed
 */
- (void)willDisplayAtTableView:(UITableView*)tableView cell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Change edition style of row at given indexPath
 @param editingStyle The cell editing style
 @param indexPath The indexPath of the cell
 */
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
         forRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Change edition style of row at given indexPath
 @param tableView tableView from object that you want
 @param editingStyle The cell editing style
 @param indexPath The indexPath of the cell
 */
- (void)commitAtTableView:(UITableView*)tableView editingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
