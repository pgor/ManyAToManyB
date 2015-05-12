//
//  MasterViewController.h
//  ManyAToManyB
//
//  Created by Paul Goracke on 3/1/15.
//  Copyright (c) 2015 Corporation Unknown. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

