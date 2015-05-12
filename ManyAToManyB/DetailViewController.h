//
//  DetailViewController.h
//  ManyAToManyB
//
//  Created by Paul Goracke on 3/1/15.
//  Copyright (c) 2015 Corporation Unknown. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface DetailViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

- (void) setFetchRequest:(NSFetchRequest*)fetchRequest title:(NSString*)title;

@end

