//
//  BKTableModelManagedListDataController.m
//  CellMappingExample
//
//  Created by Bruno Wernimont on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKManagedTableModel.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TKManagedTableModel

@synthesize searchTableView = _searchTableView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize searchFetchedResultsController = _searchFetchedResultsController;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForRowAtTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath {
    id object = [self objectForRowAtIndexPath:indexPath];
    
    if (nil == object) {
        return [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    }
    return object;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil; // force to use objectForRowAtTableView:indexPath:
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsAtTableView:(UITableView*)tableView {
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfRowsInSection:(NSInteger)section atTableView:(UITableView*)tableView {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFetchedResultsControllerWithBlock:(TKManagedTableModelFetchedResultsControllerBlock)block {
    self.fetchedResultsController = block();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSearchFetchedResultsControllerWithBlock:(TKSearchFetchedResultsControllerBlock)block {
    self.searchFetchedResultsController = block();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadItems {
    [self.fetchedResultsController performFetch:nil];
}

- (UITableViewCell *)cellForRowAtTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    id object = [self objectForRowAtTableView:tableView indexPath:indexPath];
    return [super mapCellForObject:object];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)heightForRowAtTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    id object = [self objectForRowAtTableView:tableView indexPath:indexPath];
    return [super cellHeightForObject:object indexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters and setters


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    _fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
}

- (void)setSearchFetchedResultsController:(NSFetchedResultsController *)searchFetchedResultsController {
    _searchFetchedResultsController = searchFetchedResultsController;
    _searchFetchedResultsController.delegate = self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark helper

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (UITableView *)tableViewForFetchedResultsController:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchTableView;
    return tableView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section atTableView:tableView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSectionsAtTableView:tableView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    int count = [self numberOfSectionsAtTableView:tableView];
    
    if (count > section) {
        id sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
        return [sectionInfo name];
    }
    
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellForRowAtTableView:tableView indexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowAtTableView:tableView indexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];

    [tableView beginUpdates];
    
    if ([_fetchedResultsControllerDelegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
        [_fetchedResultsControllerDelegate controllerWillChangeContent:controller];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    if ([_fetchedResultsControllerDelegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [_fetchedResultsControllerDelegate controller:controller
                                      didChangeObject:anObject
                                          atIndexPath:indexPath
                                        forChangeType:type
                                         newIndexPath:newIndexPath];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    UITableView *tableView = [self tableViewForFetchedResultsController:controller];

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    if ([_fetchedResultsControllerDelegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
        [_fetchedResultsControllerDelegate controller:controller
                                     didChangeSection:sectionInfo
                                              atIndex:sectionIndex
                                        forChangeType:type];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];
    [tableView endUpdates];
    
    if ([_fetchedResultsControllerDelegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [_fetchedResultsControllerDelegate controllerDidChangeContent:controller];
    }
}

#pragma mark - Content Filtering
- (void)filterContentForSearchPredicate:(NSPredicate*)predicate
{
    [self.searchFetchedResultsController.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![[self searchFetchedResultsController] performFetch:&error]) {
        SHError(@"Unresolved error %@, %@", error, [error userInfo]);
    }           
    
    [self.searchTableView reloadData];
}

@end
