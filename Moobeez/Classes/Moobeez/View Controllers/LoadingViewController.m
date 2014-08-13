//
//  LoadingViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "LoadingViewController.h"
#import "Moobeez.h"

@interface LoadingViewController ()

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

@property (strong, nonatomic) NSMutableArray* incompleteMoobeez;
@property (strong, nonatomic) NSMutableArray* incompleteTeebeez;

@property (readwrite, nonatomic) NSInteger numberOfTriesToUpdateMoobeez;
@property (readwrite, nonatomic) NSInteger numberOfTriesToUpdateTeebeez;

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.loadingView.alpha = 0.0;
    
    self.numberOfTriesToUpdateMoobeez = 0;
    
    [[Settings sharedSettings] loadSettings];
    [[Settings sharedSettings] deleteOldImages];

    [self performSelector:@selector(startLoading) withObject:nil afterDelay:0.01];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLoading {
    
    [[Database sharedDatabase] populateWithOldDatabase];
    
    ConfigurationConnection* connection = [[ConfigurationConnection alloc] initWithCompletionHandler:^(WebserviceResultCode code) {
        if (code == WebserviceResultOk) {
            
            [self goToSideBarController];
        }
    }];
    
    [self startConnection:connection];

}

- (BOOL)updateDatabase {
    
    self.incompleteMoobeez = [[Database sharedDatabase] incompleteMoobeez];
    
    if (self.incompleteMoobeez.count > 0 && self.numberOfTriesToUpdateMoobeez < 3) {
        
        if (self.incompleteMoobeez.count > 2) {
            [UIView animateWithDuration:0.3 animations:^{
                self.loadingView.alpha = 1.0;
            }];
        }
        
        self.numberOfTriesToUpdateMoobeez++;
        
        [self.loadingActivityIndicator startAnimating];
        [self loadNextIncompleteMovie];
        return YES;
    }

    self.incompleteTeebeez = [[Database sharedDatabase] incompleteTeebeez];
    
    if (self.incompleteTeebeez.count > 0 && self.numberOfTriesToUpdateTeebeez < 3) {
        
        if (self.incompleteTeebeez.count > 2) {
            [UIView animateWithDuration:0.3 animations:^{
                self.loadingView.alpha = 1.0;
            }];
        }
        
        self.numberOfTriesToUpdateTeebeez++;
        
        [self.loadingActivityIndicator startAnimating];
        [self loadNextIncompleteTv];
        return YES;
    }

    
    return NO;
}


- (void)loadNextIncompleteMovie {
    
    if (self.incompleteMoobeez.count == 0) {
        [self goToSideBarController];
        return;
    }
    
    Moobee* moobee = self.incompleteMoobeez[0];
    
    MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
       
        if (code == WebserviceResultOk) {
            
            moobee.releaseDate = movie.releaseDate;
            moobee.backdropPath = movie.backdropPath;
            moobee.posterPath = movie.posterPath;
            
            [moobee save];
            
        }
        
        [self.incompleteMoobeez removeObjectAtIndex:0];
        [self loadNextIncompleteMovie];
        
    }];
    
    [self startConnection:connection];
    
}

- (void)loadNextIncompleteTv {
    
    if (self.incompleteTeebeez.count == 0) {
        [self goToSideBarController];
        return;
    }
    
    Teebee* teebee = self.incompleteTeebeez[0];
    
    TvConnection* connection = [[TvConnection alloc] initWithTmdbId:teebee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
        
        if (code == WebserviceResultOk) {
            
            teebee.backdropPath = tv.backdropPath;
            teebee.posterPath = tv.posterPath;
            
            [teebee save];
            
        }
        
        [self.incompleteTeebeez removeObjectAtIndex:0];
        [self loadNextIncompleteTv];
        
    }];
    
    [self startConnection:connection];
    
}

- (void)goToSideBarController {
    
    if ([self updateDatabase]) {
        return;
    }
    
    self.loadingView.hidden = YES;
    
    [self.navigationController pushViewController:self.appDelegate.sideTabController animated:NO];
}


@end
