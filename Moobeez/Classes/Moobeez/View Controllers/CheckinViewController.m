//
//  CheckinViewController.m
//  Moobeez
//
//  Created by Radu Banea on 17/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "CheckinViewController.h"
#import "Moobeez.h"

typedef enum : NSUInteger {
    SectionSearch,
    SectionWatchlist,
    SectionsCount,
} Sections;

@interface CheckinViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, FBPlacePickerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* searchItems;
@property (strong, nonatomic) NSMutableArray* watchlistMovies;

@property (strong, nonatomic) NSIndexPath* selectedMovieIndexPath;
@property (strong, nonatomic) NSIndexPath* selectedPlaceIndexPath;

@property (strong, nonatomic) SearchNewMovieViewController* searchNewMovieController;

@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)refresh;

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Check-in to movie";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nil;
    
    self.searchText = @"Cinema";
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CheckInMovieCell" bundle:nil] forCellWithReuseIdentifier:@"CheckInMovieCell"];
    [self.placesTableView registerNib:[UINib nibWithNibName:@"CheckInPlaceCell" bundle:nil] forCellReuseIdentifier:@"CheckInPlaceCell"];
    
    self.searchItems = [[NSMutableArray alloc] init];
    self.watchlistMovies = [[Database sharedDatabase] moobeezWithType:MoobeeOnWatchlistType];
    [self.collectionView reloadData];
    
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return SectionsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (section) {
        case SectionSearch:
            return self.searchItems.count;
            break;
        case SectionWatchlist:
            return self.watchlistMovies.count;
        default:
            break;
    }
    
    return 0;
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckInMovieCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckInMovieCell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case SectionSearch:
        {
            [cell.posterImageView loadImageWithPath:[self.searchItems[indexPath.row] posterPath] andWidth:185 completion:^(BOOL didLoadImage) {
                
            }];
        }
            break;
        case SectionWatchlist:
        {
            [cell.posterImageView loadImageWithPath:[self.watchlistMovies[indexPath.row] posterPath] andWidth:185 completion:^(BOOL didLoadImage) {
                
            }];
        }
        default:
            break;
    }

    cell.checkmarkImageView.hidden = !([indexPath isEqual:self.selectedMovieIndexPath]);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedMovieIndexPath = indexPath;
    [collectionView reloadData];
    
}

- (IBAction)closeButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - Search

- (IBAction)searchButtonPressed:(id)sender {
    
    [self.searchNewMovieController prepareBlurInView:self.appDelegate.window];
    
    [self.appDelegate.window addSubview:self.searchNewMovieController.view];
    
    self.searchNewMovieController.selectHandler = ^ (TmdbMovie* movie) {
        
        [self.searchItems insertObject:movie atIndex:0];
        [self.collectionView reloadData];
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        
        [self.searchNewMovieController.view removeFromSuperview];

    };
    
}

- (SearchNewMovieViewController*)searchNewMovieController {
    if (!_searchNewMovieController) {
        _searchNewMovieController = [[SearchNewMovieViewController alloc] initWithNibName:@"SearchNewMovieViewController" bundle:nil];
        _searchNewMovieController.view.frame = self.appDelegate.window.bounds;
    }
    
    return _searchNewMovieController;
}

#pragma mark - Location

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckInPlaceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CheckInPlaceCell"];
    
    NSDictionary* place = self.data[indexPath.row];
    
    cell.nameLabel.text = place[@"name"];
    
    NSString *category = place[@"category"];
    NSNumber *wereHereCount = place[@"were_here_count"];
    
    NSString* subtitle = @"";
    
    if (wereHereCount) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *wereHere = [numberFormatter stringFromNumber:wereHereCount];
        
        if (category) {
            subtitle = [NSString stringWithFormat:@"%@ • %@ were here", [category capitalizedString], wereHere];
        }
        subtitle = [NSString stringWithFormat:@"%@ were here", wereHere];
    }
    if (category) {
        subtitle = [category capitalizedString];
    }
    
    cell.detailsLabel.text = subtitle;
    
    [cell.iconView loadImageWithPath:place[@"picture"][@"data"][@"url"] completion:^(BOOL didLoadImage) {}];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.checkmarkImageView.hidden = (indexPath != self.selectedPlaceIndexPath);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedPlaceIndexPath = indexPath;
    [tableView reloadData];
    
}



@end
