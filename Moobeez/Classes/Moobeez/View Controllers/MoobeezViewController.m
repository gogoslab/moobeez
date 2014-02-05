//
//  MoobeezViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MoobeezViewController.h"
#import "Moobeez.h"

enum CollectionSections {
    SearchSection = 0,
    MoobeezSection,
    EmptySection,
    SectionsCount
    };

@interface MoobeezViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* moobeez;
@property (strong, nonatomic) NSArray* displayedMoobeez;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (strong, nonatomic) UICollectionViewCell *searchCell;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (readwrite, nonatomic) CGFloat initialCollectionViewHeight;

@property (strong, nonatomic) MoobeeCell* animationCell;

@property (strong, nonatomic) SearchNewMovieViewController* searchNewMovieController;

@property (readonly, nonatomic) MoobeeType selectedType;

@end

@implementation MoobeezViewController

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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MoobeeCell" bundle:nil] forCellWithReuseIdentifier:@"MoobeeCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"EmptyCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SearchCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMoobeez) name:DatabaseDidReloadNotification object:nil];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    addButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    static BOOL firstAppear = YES;
    
    if (firstAppear) {
        self.initialCollectionViewHeight = self.collectionView.height;

        [self reloadMoobeez];
    
        firstAppear = NO;
        
        self.collectionView.contentOffset = CGPointMake(0, 0);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

#pragma mark - Collection View

- (MoobeeType)selectedType {
    return (MoobeeType) (2 - self.typeSegmentedControl.selectedSegmentIndex);
}

- (void)reloadMoobeez {
    
    switch (self.selectedType) {
        case MoobeeSeenType:
            self.moobeez = [[Database sharedDatabase] moobeezWithType:MoobeeSeenType];
            break;
        case MoobeeOnWatchlistType:
            self.moobeez = [[Database sharedDatabase] moobeezWithType:MoobeeOnWatchlistType];
            break;
        case MoobeeFavoriteType:
            self.moobeez = [[Database sharedDatabase] favoritesMoobeez];
            break;
        default:
            break;
    }
    
    self.searchBar.text = @"";
    [self applyFilter];
    
    [self reloadData];
    
    self.collectionView.contentOffset = CGPointMake(0, -60);
    
}

- (void)applyFilter {
    self.displayedMoobeez = [self.moobeez filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if (self.searchBar.text.length == 0 || [((Moobee*) evaluatedObject).name rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location !=  NSNotFound) {
            return YES;
        }
        return NO;
    }]];
}

- (void)reloadData {

    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return SectionsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (section) {
        case SearchSection:
            return 1;
            break;
        case MoobeezSection:
            return self.displayedMoobeez.count;
            break;
        case EmptySection:
            return 1;
            break;
        default:
            break;
    }
    
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SearchSection) {
        
        self.searchCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];
        if (!self.searchBar.superview) {
            self.searchCell.frame = self.searchBar.frame;
            [self.searchCell addSubview:self.searchBar];
        }
        
        return self.searchCell;
    }
    
    if (indexPath.section == EmptySection) {
        UICollectionViewCell* emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCell" forIndexPath:indexPath];
        emptyCell.backgroundColor = [UIColor clearColor];
        return emptyCell;
    }
    
    MoobeeCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoobeeCell" forIndexPath:indexPath];

    cell.moobee = self.displayedMoobeez[indexPath.row];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SearchSection) {
        
        return CGSizeMake(296, 10);
        
    }
    
    if (indexPath.section == EmptySection) {
        
        return CGSizeMake(296, MAX(0, self.collectionView.height - [MoobeeCell cellHeight] * (self.displayedMoobeez.count - 1 / 3 + 1)));
        
    }
    
    return CGSizeMake(90, [MoobeeCell cellHeight]);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MoobeezSection) {
        
        MoobeeCell* cell = (MoobeeCell*) [collectionView cellForItemAtIndexPath:indexPath];
        
        Moobee* moobee = self.displayedMoobeez[indexPath.row];
        
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            
            if (code == WebserviceResultOk) {
                [self.view addSubview:self.animationCell];
                self.animationCell.frame = [self.view convertRect:cell.frame fromView:cell.superview];
                
                self.animationCell.moobee = moobee;
                
                [self.animationCell animateGrowWithCompletion:^{
                    
                    self.view.userInteractionEnabled = YES;
                    
                    [self goToMovieDetailsScreenForMoobee:moobee andMovie:movie];
                    
                    [self.animationCell removeFromSuperview];
                }];
            }
        }];
        
        connection.activityIndicator = cell.activityIndicator;
        [self.connectionsManager startConnection:connection];
        
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - Animations

- (MoobeeCell*)animationCell {
    if (!_animationCell) {
        _animationCell = [[NSBundle mainBundle] loadNibNamed:@"MoobeeCell" owner:self options:nil][0];
    }
    return _animationCell;
}

- (void)hideMoobee:(Moobee*)moobee {
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.displayedMoobeez indexOfObject:moobee] inSection:MoobeezSection];
 
    MoobeeCell* cell = (MoobeeCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        [self performSelector:@selector(hideMoobee:) withObject:moobee afterDelay:0.01];
        return;
    }
    
    cell.moobee = moobee;
    
    [self.view addSubview:self.animationCell];
    self.animationCell.frame = [self.view convertRect:cell.frame fromView:cell.superview];
    
    [self.animationCell animateShrinkWithCompletion:^{
        [self.animationCell removeFromSuperview];
    }];

}

- (void)goToMovieDetailsScreenForMoobee:(Moobee*)moobee andMovie:(TmdbMovie*)movie {
    
    MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
    viewController.moobee = moobee;
    viewController.tmdbMovie = movie;
    [self presentViewController:viewController animated:NO completion:^{}];
    
    viewController.closeHandler = ^{
        
        if (moobee.id == -1) {
            return;
        }
        
        // change type moobee
        
        BOOL sameType;
        if (self.selectedType == MoobeeFavoriteType) {
            sameType = moobee.isFavorite;
        }
        else {
            sameType = (moobee.type == self.selectedType);
        }
        
        if (!sameType) {
            if ([self.moobeez containsObject:moobee]) {
                [self.moobeez removeObject:moobee];
                [self applyFilter];
                [self.collectionView reloadData];
            }
            
            return;
        }
        
        // new moobee
        if (![self.moobeez containsObject:moobee]) {
            [self.moobeez addObject:moobee];
        }
        
        if (self.selectedType != MoobeeOnWatchlistType) {
            [self.moobeez sortUsingSelector:@selector(compareByDate:)];
        }
        else {
            [self.moobeez sortUsingSelector:@selector(compareById:)];
        }
        
        [self applyFilter];
        
        [self.collectionView reloadData];
        
        self.animationCell.moobee = moobee;
        [self.animationCell prepareForShrink];
        
        [self performSelector:@selector(hideMoobee:) withObject:moobee afterDelay:0.01];
    };
    
}

#pragma mark - Type

- (IBAction)typeSegmentedControlValueChanged:(id)sender {
    
    [self reloadMoobeez];

}

#pragma mark - Add Moobee

- (void)addButtonPressed:(id)sender {
    
    [self.searchNewMovieController prepareBlurInView:self.appDelegate.window];
    
    [self.appDelegate.window addSubview:self.searchNewMovieController.view];
    
    self.searchNewMovieController.selectHandler = ^ (TmdbMovie* movie) {
        
        Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
        
        if (moobee.id == -1) {
            switch (self.selectedType) {
                case MoobeeSeenType:
                    moobee.type = MoobeeSeenType;
                    moobee.date = [NSDate date];
                    moobee.rating = 2.5;
                    break;
                case MoobeeOnWatchlistType:
                    moobee.type = MoobeeOnWatchlistType;
                    break;
                case MoobeeFavoriteType:
                    moobee.type = MoobeeNoneType;
                    moobee.isFavorite = YES;
                    break;
                default:
                    break;
            }
        }
        
        self.view.userInteractionEnabled = NO;
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            if (code == WebserviceResultOk) {
                self.view.userInteractionEnabled = YES;
                [self.searchNewMovieController.view removeFromSuperview];
                [self goToMovieDetailsScreenForMoobee:moobee andMovie:movie];
            }
        }];
        [self startConnection:connection];
    };
}

- (SearchNewMovieViewController*)searchNewMovieController {
    if (!_searchNewMovieController) {
        _searchNewMovieController = [[SearchNewMovieViewController alloc] initWithNibName:@"SearchNewMovieViewController" bundle:nil];
        _searchNewMovieController.view.frame = self.appDelegate.window.bounds;
    }
    
    return _searchNewMovieController;
}

#pragma mark - Filter

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self applyFilter];
    [self reloadData];
    self.collectionView.contentOffset = CGPointMake(0, -60);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self applyFilter];
    [self reloadData];
}

@end
