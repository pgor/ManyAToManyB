//
//  AppDelegate.m
//  ManyAToManyB
//
//  Created by Paul Goracke on 3/1/15.
//  Copyright (c) 2015 Corporation Unknown. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"A"];
    request.resultType = NSCountResultType;
    NSError* error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    if ( count == NSNotFound ) {
        NSLog(@"ERROR: %@", error);
    }
    else if ( count == 0 ) {
        NSLog(@"Adding data");
        NSInteger index = 1;
        NSInteger maxNumRecords = 10000;
        
        // Create a format strings that pads out "name" with zeros so we can sort the display
        NSInteger numPlaces = log10(maxNumRecords) + 1;
        NSString* formatString = [NSString stringWithFormat:@"%%0%zdzd", numPlaces];
        
        while ( index <= maxNumRecords ) {
            NSString* name = [NSString stringWithFormat:formatString, index];
            NSManagedObject* objectA = [NSEntityDescription insertNewObjectForEntityForName:@"A" inManagedObjectContext:self.managedObjectContext];
            [objectA setValue:name forKey:@"name"];
            
            NSManagedObject* objectB = [NSEntityDescription insertNewObjectForEntityForName:@"B" inManagedObjectContext:self.managedObjectContext];
            [objectB setValue:name forKey:@"name"];
            
            // Don't connect every 100th pair. These will be our target result set.
            if ( index % 100 != 0 ) {
                [[objectA mutableSetValueForKey:@"manyBs"] addObject:objectB];
            }
            
            index++;
        }
        
        NSError* error = nil;
        BOOL saved = [self.managedObjectContext save:&error];
        if ( ! saved ) {
            NSLog(@"ERROR saving test data: %@", error);
            abort();
        }
        else {
            NSLog(@"Data ready");
        }
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.corporationunknown.radar.ManyAToManyB" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ManyAToManyB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ManyAToManyB.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
