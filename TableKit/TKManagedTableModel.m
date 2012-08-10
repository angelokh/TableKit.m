//
//  BKTableModelManagedListDataController.m
//  CellMappingExample
//
//  Created by Bruno Wernimont on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKManagedTableModel.h"

@interface TKManagedTableModel () {
@private
    BOOL sectionHasChanged;
    NSUInteger sectionInsertCount;
}

@end
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
    sectionHasChanged = NO;
    sectionInsertCount = 0;
    UITableView *fetchTableView = [self tableViewForFetchedResultsController:controller];

    [fetchTableView beginUpdates];
    
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
    
    UITableView *fetchTableView = [self tableViewForFetchedResultsController:controller];

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [fetchTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [fetchTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        
        // http://iphonedevelopment.blogspot.com/2010/03/my-last-word-on-nsfetchedresultscontrol.html
        /*case NSFetchedResultsChangeUpdate: {
            NSString *sectionKeyPath = [controller sectionNameKeyPath];
            if (sectionKeyPath == nil)
                break;
            NSManagedObject *changedObject = [controller objectAtIndexPath:indexPath];
            NSArray *keyParts = [sectionKeyPath componentsSeparatedByString:@"."];
            id currentKeyValue = [changedObject valueForKeyPath:sectionKeyPath];
            for (int i = 0; i < [keyParts count] - 1; i++) {
                NSString *onePart = [keyParts objectAtIndex:i];
                changedObject = [changedObject valueForKey:onePart];
            }
            sectionKeyPath = [keyParts lastObject];
            NSDictionary *committedValues = [changedObject committedValuesForKeys:nil];
            
            if ([[committedValues valueForKeyPath:sectionKeyPath] isEqual:currentKeyValue])
                break;
            
            NSUInteger tableSectionCount = [fetchTableView numberOfSections];
            NSUInteger frcSectionCount = [[controller sections] count];
            if (tableSectionCount + sectionInsertCount != frcSectionCount) {
                // Need to insert a section
                NSArray *sections = controller.sections;
                NSInteger newSectionLocation = -1;
                for (id oneSection in sections) {
                    NSString *sectionName = [oneSection name];
                    if ([currentKeyValue isEqual:sectionName]) {
                        newSectionLocation = [sections indexOfObject:oneSection];
                        break;
                    }
                }
                if (newSectionLocation == -1)
                    return; // uh oh
                
                if (!((newSectionLocation == 0) && (tableSectionCount == 1) && ([fetchTableView numberOfRowsInSection:0] == 0))) {
                    [fetchTableView insertSections:[NSIndexSet indexSetWithIndex:newSectionLocation] withRowAnimation:UITableViewRowAnimationFade];
                    sectionInsertCount++;
                }
                
                NSUInteger indices[2] = {newSectionLocation, 0};
                newIndexPath = [[NSIndexPath alloc] initWithIndexes:indices length:2];
            }
        }
        case NSFetchedResultsChangeMove: {
            if (newIndexPath != nil) {
                NSUInteger tableSectionCount = [fetchTableView numberOfSections];
                NSUInteger frcSectionCount = [[controller sections] count];
                if (frcSectionCount != tableSectionCount + sectionInsertCount)  {
                    [fetchTableView insertSections:[NSIndexSet indexSetWithIndex:[newIndexPath section]] withRowAnimation:UITableViewRowAnimationNone];
                    sectionInsertCount++;
                }
                
                [fetchTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [fetchTableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationRight];
                
            }
            else {
                [fetchTableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        }
        default:
            break;*/
        case NSFetchedResultsChangeUpdate:
            [fetchTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
            [fetchTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            [fetchTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
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
- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    UITableView *fetchTableView = [self tableViewForFetchedResultsController:controller];
    /*switch(type) {
            
        case NSFetchedResultsChangeInsert:
            if (!((sectionIndex == 0) && ([fetchTableView numberOfSections] == 1))) {
                [fetchTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                sectionInsertCount++;
            }
            break;
        case NSFetchedResultsChangeDelete:
            if (!((sectionIndex == 0) && ([fetchTableView numberOfSections] == 1) )) {
                [fetchTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                sectionInsertCount--;
            }
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate: 
            break;
        default:
            break;
    }*/
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [fetchTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [fetchTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    sectionHasChanged = YES;
    if ([_fetchedResultsControllerDelegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
        [_fetchedResultsControllerDelegate controller:controller
                                     didChangeSection:sectionInfo
                                              atIndex:sectionIndex
                                        forChangeType:type];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    UITableView *fetchTableView = [self tableViewForFetchedResultsController:controller];
    [fetchTableView endUpdates];
    //reload all sections
    if(sectionHasChanged){
        [fetchTableView reloadSections:[NSIndexSet 
                                   indexSetWithIndexesInRange:NSMakeRange(0, fetchTableView.numberOfSections)] 
                      withRowAnimation:UITableViewRowAnimationNone];
    }
    if ([_fetchedResultsControllerDelegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [_fetchedResultsControllerDelegate controllerDidChangeContent:controller];
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
