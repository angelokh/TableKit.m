//
//  BKTableModelManagedListDataController.h
//  CellMappingExample
//
//  Created by Bruno Wernimont on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "TKTableModel.h"

typedef NSFetchedResultsController*(^TKManagedTableModelFetchedResultsControllerBlock)();
typedef NSFetchedResultsController*(^TKSearchFetchedResultsControllerBlock)();

@interface TKManagedTableModel : TKTableModel<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView* searchTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) id<NSFetchedResultsControllerDelegate, NSObject> fetchedResultsControllerDelegate;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

/**
 Return the number of section from model
 @return The number of section from model
 */
- (NSInteger)numberOfSectionsAtTableView:(UITableView*)tableView;

/**
 Return the number of rows in section from model
 @param section An index number that identifies a section of the model
 @return The number of rows
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section atTableView:(UITableView*)tableView;

/**
 Setter for the fetched controller block creation
 @param block Block that will be called to created the fetched result controller
 */
- (void)setFetchedResultsControllerWithBlock:(TKManagedTableModelFetchedResultsControllerBlock)block;

/**
 Setter for the search fetched controller block creation
 @param block Block that will be called to created the search fetched result controller
 */
- (void)setSearchFetchedResultsControllerWithBlock:(TKSearchFetchedResultsControllerBlock)block;

#pragma mark - Content Filtering
/**
 Setter for the search fetched controller predicate
 @param predicate Predicate for the search fetched result controller
 */
- (void)filterContentForSearchPredicate:(NSPredicate*)predicate;

@end
