//
//  MissedViewController.m
//  Missed Shows
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "MissedViewController.h"
#import "BasicDatabase.h"
#import "NSDate+Calculator.h"
#import <NotificationCenter/NotificationCenter.h>

@interface MissedViewController () <NCWidgetProviding>

@end

@implementation MissedViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (NSString*)query {
    
    NSTimeInterval endDate = [[[NSDate date] resetToLateMidnight] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"SELECT Teebeez.name, Teebeez.posterPath, Episodes.seasonNumber, Episodes.episodeNumber FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId) WHERE (Episodes.airDate <> '(null)' AND Episodes.airDate <= '%f' AND watched = '0') ORDER BY Episodes.airDate LIMIT 9", endDate];
}
@end
