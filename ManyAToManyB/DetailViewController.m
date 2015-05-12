//
//  DetailViewController.m
//  ManyAToManyB
//
//  Created by Paul Goracke on 3/1/15.
//  Copyright (c) 2015 Corporation Unknown. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchRequest* fetchRequest;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@end

@implementation DetailViewController

- (void) setFetchRequest:(NSFetchRequest*)fetchRequest title:(NSString*)title {
    self.fetchRequest = fetchRequest;
    self.title = title;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];
}

- (NSFetchedResultsController*) fetchedResultsController {
    if ( self->_fetchedResultsController == nil ) {
        // Configure the request's entity, and optionally its predicate.
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [self.fetchRequest setSortDescriptors:@[ sortDescriptor ]];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:self.fetchRequest
                                                  managedObjectContext:self.managedObjectContext
                                                  sectionNameKeyPath:nil
                                                  cacheName:nil];
        
        NSError *error;
        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
        BOOL success = [controller performFetch:&error];
        NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
        if ( ! success ) {
            NSLog(@"ERROR: %@", error);
        }
        else {
            self->_fetchedResultsController = controller;
            self.navigationItem.prompt = [NSString stringWithFormat:@"%tu items in %.4f secs",
                                          [[controller fetchedObjects] count],
                                          (end - start),
                                          nil];
        }
    }
    
    return self->_fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"name"];
    // Configure the cell with data from the managed object.
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate


@end
