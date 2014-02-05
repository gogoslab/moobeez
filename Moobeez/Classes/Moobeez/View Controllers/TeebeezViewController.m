//
//  TeebeezViewController.m
//  Teebeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TeebeezViewController.h"
#import "Moobeez.h"

enum CollectionSections {
    SearchSection = 0,
    TeebeezSection,
    EmptySection,
    SectionsCount
    };

@interface TeebeezViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* teebeez;
@property (strong, nonatomic) NSArray* displayedTeebeez;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (strong, nonatomic) UICollectionViewCell *searchCell;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (readwrite, nonatomic) CGFloat initialCollectionViewHeight;

@property (strong, nonatomic) BeeCell* animationCell;

@property (strong, nonatomic) SearchNewTvViewController* searchNewTvViewController;

@property (readonly, nonatomic) TeebeeType selectedType;

@end

@implementation TeebeezViewController

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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"BeeCell" bundle:nil] forCellWithReuseIdentifier:@"BeeCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"EmptyCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SearchCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTeebeez) name:DatabaseDidReloadNotification object:nil];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    addButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    static BOOL firstAppear = YES;
    
    if (firstAppear) {
        self.initialCollectionViewHeight = self.collectionView.height;

        [self reloadTeebeez];
    
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

- (TeebeeType)selectedType {
    return (TeebeeType) (self.typeSegmentedControl.selectedSegmentIndex + 1);
}

- (void)reloadTeebeez {
    
    switch (self.selectedType) {
        case TeebeeToSeeType:
            self.teebeez = [[Database sharedDatabase] teebeezWithType:TeebeeToSeeType];
            break;
        case TeebeeSoonType:
            self.teebeez = [[Database sharedDatabase] teebeezWithType:TeebeeSoonType];
            break;
        case TeebeeAllType:
            self.teebeez = [[Database sharedDatabase] teebeezWithType:TeebeeAllType];
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
    self.displayedTeebeez = [self.teebeez filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
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
        case TeebeezSection:
            return self.displayedTeebeez.count;
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
    
    BeeCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BeeCell" forIndexPath:indexPath];

    cell.bee = self.displayedTeebeez[indexPath.row];
    cell.notWatchedEpisodesLabel.alpha = (self.selectedType == TeebeeSoonType ? 0.0 : 1.0);
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SearchSection) {
        
        return CGSizeMake(296, 10);
        
    }
    
    if (indexPath.section == EmptySection) {
        
        return CGSizeMake(296, MAX(0, self.collectionView.height - [BeeCell cellHeight] * (self.displayedTeebeez.count - 1 / 3 + 1)));
        
    }
    
    return CGSizeMake(90, [BeeCell cellHeight]);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TeebeezSection) {
        
        BeeCell* cell = (BeeCell*) [collectionView cellForItemAtIndexPath:indexPath];
        
        Teebee* teebee = self.displayedTeebeez[indexPath.row];
        
        TvConnection* connection = [[TvConnection alloc] initWithTmdbId:teebee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
            
            if (code == WebserviceResultOk) {
                [self.view addSubview:self.animationCell];

                self.animationCell.frame = [self.view convertRect:cell.frame fromView:cell.superview];
                
                self.animationCell.bee = teebee;
                
                [self.animationCell animateGrowWithCompletion:^{
                    
                    self.view.userInteractionEnabled = YES;
                    
                    if (self.selectedType == TeebeeSoonType) {
                        [[Database sharedDatabase] pullTeebeezEpisodesCount:teebee];
                    }
                    
                    [self goToTvDetailsScreenForTeebee:teebee andTv:tv];
                }];
            }
        }];
        
        connection.activityIndicator = cell.activityIndicator;
        [self.connectionsManager startConnection:connection];
        
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - Animations

- (BeeCell*)animationCell {
    if (!_animationCell) {
        _animationCell = [[NSBundle mainBundle] loadNibNamed:@"BeeCell" owner:self options:nil][0];
    }
    return _animationCell;
}

- (void)hideMoobee:(Moobee*)moobee {
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.displayedTeebeez indexOfObject:moobee] inSection:TeebeezSection];
 
    BeeCell* cell = (BeeCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        [self performSelector:@selector(hideMoobee:) withObject:moobee afterDelay:0.01];
        return;
    }
    
    cell.bee = moobee;
    
    [self.view addSubview:self.animationCell];
    self.animationCell.frame = [self.view convertRect:cell.frame fromView:cell.superview];
    
    [self.animationCell animateShrinkWithCompletion:^{
        [self.animationCell removeFromSuperview];
    }];

}

- (void)goToTvDetailsScreenForTeebee:(Teebee*)teebee andTv:(TmdbTV*)tv {
    
    TvViewController* viewController = [[TvViewController alloc] initWithNibName:@"TvViewController" bundle:nil];
    viewController.teebee = teebee;
    viewController.tmdbTv = tv;
    [self presentViewController:viewController animated:NO completion:^{}];
    
    viewController.closeHandler = ^{
        
        if (teebee.id == -1) {
            return;
        }
        
        // new moobee
        if (![self.teebeez containsObject:teebee]) {
            [self.teebeez addObject:teebee];
        }
        
//        if (self.selectedType != MoobeeOnWatchlistType) {
//            [self.teebeez sortUsingSelector:@selector(compareByDate:)];
//        }
//        else {
//            [self.teebeez sortUsingSelector:@selector(compareById:)];
//        }
        
        [self applyFilter];
        
        [self.collectionView reloadData];
        
        self.animationCell.bee = teebee;
        [self.animationCell prepareForShrink];
        
        [self performSelector:@selector(hideMoobee:) withObject:teebee afterDelay:0.01];
    };
    
}

#pragma mark - Type

- (IBAction)typeSegmentedControlValueChanged:(id)sender {
    
    [self reloadTeebeez];

}

#pragma mark - Add Moobee

- (void)addButtonPressed:(id)sender {
    
    [self.searchNewTvViewController prepareBlurInView:self.appDelegate.window];

    [self.appDelegate.window addSubview:self.searchNewTvViewController.view];
    
    self.searchNewTvViewController.selectHandler = ^ (TmdbTV* tv) {
        
        Teebee* teebee = [Teebee teebeeWithTmdbTV:tv];
        
        self.view.userInteractionEnabled = NO;

        TvConnection* connection = [[TvConnection alloc] initWithTmdbId:teebee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
            if (code == WebserviceResultOk) {
                self.view.userInteractionEnabled = YES;
                [self.searchNewTvViewController.view removeFromSuperview];
                [self goToTvDetailsScreenForTeebee:teebee andTv:tv];
            }
        }];
        [self startConnection:connection];
    };
}

- (SearchNewTvViewController*)searchNewTvViewController {
    if (!_searchNewTvViewController) {
        _searchNewTvViewController = [[SearchNewTvViewController alloc] initWithNibName:@"SearchNewTvViewController" bundle:nil];
        _searchNewTvViewController.view.frame = self.appDelegate.window.bounds;
    }
    
    return _searchNewTvViewController;
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
