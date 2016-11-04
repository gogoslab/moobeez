//
//  PlacePickerViewController.m
//  Moobeez
//
//  Created by Radu Banea on 21/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "PlacePickerViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>

const NSInteger defaultResultsLimit = 10;
const NSInteger defaultRadius = 10000; // 1km

@interface PlacePickerViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) NSString* nextUrlRequest;

@property (copy, nonatomic) FBRequestHandler requestHandler;

@property (readwrite, nonatomic) BOOL isLoading;


@end

@implementation PlacePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchText = @"";
    self.radius = defaultRadius;
    self.resultsLimit = defaultResultsLimit;
    
    [self.placesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.locationManager = [[CLLocationManager alloc] init];

    __block PlacePickerViewController *weakSelf = self;

    self.requestHandler = ^(FBRequestConnection *connection, id result, NSError *error) {
        weakSelf.isLoading = NO;

        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            //NSLog(@"Result: %@", result);
            
            [weakSelf processResult:result];
            
        }};

}

- (void)loadFqlData {

    NSString* query = [NSString stringWithFormat:@"SELECT name, display_subtext, page_id, pic, type FROM place WHERE distance(latitude, longitude, \"%.7f\", \"%.7f\") < %ld AND ", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, (long)self.radius];
    
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:self.requestHandler];
    
}

- (void)loadData {
    
    
    if (FBSession.activeSession.isOpen) {

        self.isLoading = YES;
        
        if (!self.nextUrlRequest) {
            
            FBRequest* request = [FBRequest requestForPlacesSearchAtCoordinate:self.locationManager.location.coordinate radiusInMeters:self.radius resultsLimit:self.resultsLimit searchText:self.searchText];
            
            request.parameters[@"fields"] = @"id, name, category, picture, were_here_count";
            
            FBRequestConnection* connection = [[FBRequestConnection alloc] init];
            [connection addRequest:request completionHandler:self.requestHandler];
            [connection start];
            
//            [FBRequestConnection startForPlacesSearchAtCoordinate:self.locationManager.location.coordinate radiusInMeters:defaultRadius resultsLimit:defaultResultsLimit searchText:@"Cinema" completionHandler:self.requestHandler];
        }
        else {
            [FBRequestConnection startWithGraphPath:self.nextUrlRequest completionHandler:self.requestHandler];
        }
    }
}

- (void)processResult:(id)result {
    
    NSMutableArray* newData = result[@"data"];
    
    if (!self.data) {
        self.data = [[NSMutableArray alloc] init];
    }
    
    [self.data addObjectsFromArray:newData];
    
    self.nextUrlRequest = result[@"paging"][@"next"];
    
    [self.placesTableView reloadData];
    
    [self.placesActivityIndicator stopAnimating];
    
}

- (void)refresh {
    // if the session is open, then load the data for our view controller
    if (FBSession.activeSession.isOpen) {
        // Default to Seattle, this method calls loadData
        
        self.locationManager.delegate = self;

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.locationManager startUpdatingLocation];
        }
        else {
            [self.locationManager requestWhenInUseAuthorization];
        }

    }
}

#pragma mark - Location Manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (newLocation.horizontalAccuracy < 100) {
        // We wait for a precision of 100m and turn the GPS off
        [self.locationManager stopUpdatingLocation];
        
        self.locationManager.delegate = nil;
        
        [self loadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
    
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = self.data[indexPath.row][@"name"];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.isLoading && scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + 40)) {
        [self loadData];
    }
    
}

@end
