//
//  MasterViewController.m
//  ManyAToManyB
//
//  Created by Paul Goracke on 3/1/15.
//  Copyright (c) 2015 Corporation Unknown. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property (nonatomic, strong) NSArray* rows;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSMutableArray* rows = [NSMutableArray array];
    NSFetchRequest* request;
    
    /*
     The first two predicates demonstrate that A->B @count and B->A @count do not
     perform symmetrically. In testing, B->A is orders of magnitude slower since it
     does not use the join table's compound index.
     (Since the A<->B join table is a Core Data implementation detail, it's possible
     but unlikely that A->B performance will be slower.)
     */
    
    // Request "As via @count".
    // Performs well.
    request = [NSFetchRequest fetchRequestWithEntityName:@"A"];
    request.predicate = [NSPredicate predicateWithFormat:@"manyBs.@count == 0"];
    [rows addObject:@{ @"title" : @"Unattached As via @count",
                       @"fetchRequest" : request,
                       }];
    
    // Request "Bs via @count".
    // This request will take orders of magnitude slower than "As via @count".
    request = [NSFetchRequest fetchRequestWithEntityName:@"B"];
    request.predicate = [NSPredicate predicateWithFormat:@"manyAs.@count == 0"];
    [rows addObject:@{ @"title" : @"Unattached Bs via @count",
                       @"fetchRequest" : request,
                       }];

    // Request "As via ANY".
    // This seems to be the intuitive way to write this query, but it crashes with 'Unsupported predicate ALL manyBs == nil'
    request = [NSFetchRequest fetchRequestWithEntityName:@"A"];
    request.predicate = [NSPredicate predicateWithFormat:@"ALL manyBs == nil"];
    [rows addObject:@{ @"title" : @"Unattached As via ALL (crash)",
                       @"fetchRequest" : request,
                       }];
    
    /*
     Using the following two predicates causes the generated query to traverse
     the join table, allowing its compound index to be used.
     The performance observed is therefore symmetrical.
     This is the desired result.
     */
    
    // Request "As via NONE".
    // Performs well.
    request = [NSFetchRequest fetchRequestWithEntityName:@"A"];
    request.predicate = [NSPredicate predicateWithFormat:@"NONE manyBs != nil"];
    [rows addObject:@{ @"title" : @"Unattached As via NONE",
                       @"fetchRequest" : request,
                       }];

    // Request "Bs via NONE".
    // Performs well.
    request = [NSFetchRequest fetchRequestWithEntityName:@"B"];
    request.predicate = [NSPredicate predicateWithFormat:@"NONE manyAs != nil"];
    [rows addObject:@{ @"title" : @"Unattached Bs via NONE",
                       @"fetchRequest" : request,
                       }];

    self.rows = rows;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary* rowObject = self.rows[ indexPath.row ];
        DetailViewController* controller = [segue destinationViewController];
        controller.managedObjectContext = self.managedObjectContext;
        [controller setFetchRequest:rowObject[@"fetchRequest"] title:rowObject[@"title"]];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* rowObject = self.rows[ indexPath.row ];
    cell.textLabel.text = rowObject[ @"title" ];
}


@end
