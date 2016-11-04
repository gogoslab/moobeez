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
    EmptySection = TeebeezSection,
    SectionsCount
    };

typedef enum SoonSections {
    TodaySection = 0,
    TommorowSection,
    ThisWeekSection,
    SoonSection,
    SoonSectionsCount
    } SoonSections;

@interface TeebeezViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* teebeez;
@property (strong, nonatomic) NSMutableArray* displayedTeebeez;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (strong, nonatomic) UICollectionViewCell *searchCell;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (readwrite, nonatomic) CGFloat initialCollectionViewHeight;

@property (strong, nonatomic) BeeCell* animationCell;

@property (strong, nonatomic) SearchNewTvViewController* searchNewTvViewController;

@property (readonly, nonatomic) TeebeeType selectedType;


@property (strong, nonatomic) NSMutableArray* teebeezToUpdate;
@property (readwrite, nonatomic) NSInteger numberOfTeebeezToUpdate;

@property (strong, nonatomic) IBOutlet UIView *updatingView;
@property (weak, nonatomic) IBOutlet UILabel *updatingLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *updatingProgressBar;

@property (readwrite, nonatomic) BOOL isUpdating;

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
    [self.collectionView registerNib:[UINib nibWithNibName:@"TeebeezHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TeebeezHeaderView"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTeebeez) name:TeebeezDidReloadNotification object:nil];
    
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
        
    }
    
    if (!self.isUpdating) {

        self.isUpdating = YES;
        
        self.teebeezToUpdate = [[Database sharedDatabase] teebeezToUpdate];

        if (self.teebeezToUpdate.count) {
            
            [Alert showAlertViewWithTitle:@"Teebeez outdated" message:@"Do you want to update the teebeez now?" buttonClickedCallback:^(NSInteger buttonIndex) {
                
                if (buttonIndex == 1) {
                    [self updateTeebeez];
                }
                else {
                    self.isUpdating = NO;
                }
                
            } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            
        }
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
    
}

- (void)applyFilter {
    NSArray* filteredTeebeez = [self.teebeez filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if (self.searchBar.text.length == 0 || [((Moobee*) evaluatedObject).name rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location !=  NSNotFound) {
            return YES;
        }
        return NO;
    }]];
    
    if (self.selectedType == TeebeeSoonType) {
        NSArray* sortedTeebeez = [filteredTeebeez sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((Teebee*) obj1).nextEpisode.airDate compare:((Teebee*) obj2).nextEpisode.airDate];
        }];
        
        self.displayedTeebeez = [[NSMutableArray alloc] initWithCapacity:SoonSectionsCount];
        
        for (int i = 0; i < SoonSectionsCount; ++i) {
            [self.displayedTeebeez addObject:[[NSMutableArray alloc] init]];
        }
        
        for (Teebee* teebee in sortedTeebeez) {
            
            NSInteger numberOfDays = [[[teebee.nextEpisode.airDate teebeeDisplayDate] resetToMidnight] timeIntervalSinceDate:[[NSDate date] resetToMidnight]] / (24 * 3600);

            if (numberOfDays == 0) {
                [self.displayedTeebeez[TodaySection] addObject:teebee];
            }
            else if (numberOfDays == 1) {
                [self.displayedTeebeez[TommorowSection] addObject:teebee];
            }
            else if (numberOfDays < 7) {
                [self.displayedTeebeez[ThisWeekSection] addObject:teebee];
            }
            else {
                [self.displayedTeebeez[SoonSection] addObject:teebee];
            }
        }
    }
    else {
        self.displayedTeebeez = [NSMutableArray arrayWithObject:filteredTeebeez];
    }
}

- (void)reloadData {

    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return SectionsCount + self.displayedTeebeez.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section == SearchSection || section == EmptySection + self.displayedTeebeez.count) {
        return 1;
    }
    
    section -= TeebeezSection;
    
    return [self.displayedTeebeez[section] count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SearchSection) {
        
        self.searchCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCell" forIndexPath:indexPath];
        if (!self.searchBar.superview) {
            self.searchCell.frame = self.searchBar.frame;
            [self.searchCell addSubview:self.searchBar];
            self.searchCell.width = collectionView.width - 24;
            self.searchBar.width = collectionView.width - 24;
        }
        
        return self.searchCell;
    }
    
    if (indexPath.section == EmptySection + self.displayedTeebeez.count) {
        UICollectionViewCell* emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCell" forIndexPath:indexPath];
        emptyCell.backgroundColor = [UIColor clearColor];
        return emptyCell;
    }
    
    NSInteger section = indexPath.section - TeebeezSection;
    BeeCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BeeCell" forIndexPath:indexPath];

    cell.bee = self.displayedTeebeez[section][indexPath.row];
    cell.notWatchedEpisodesLabel.alpha = (self.selectedType == TeebeeSoonType ? 0.0 : 1.0);
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SearchSection) {
        
        return CGSizeMake(collectionView.width - 24, 10);
        
    }
    
    if (indexPath.section == EmptySection + self.displayedTeebeez.count) {
        
        NSInteger numberOfLines = 0;
        
        for (NSMutableArray* teebeezSection in self.displayedTeebeez) {
            numberOfLines += (teebeezSection.count == 0 ? 0 : teebeezSection.count - 1 / 3 + 1);
        }
        
        return CGSizeMake(296, MAX(0, self.collectionView.height - [BeeCell cellHeight] * numberOfLines));
        
    }
    
    return CGSizeMake(90, [BeeCell cellHeight]);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= TeebeezSection && indexPath.section < TeebeezSection + self.displayedTeebeez.count) {
        
        BeeCell* cell = (BeeCell*) [collectionView cellForItemAtIndexPath:indexPath];
        
        Teebee* teebee = self.displayedTeebeez[indexPath.section - TeebeezSection][indexPath.row];
        
        TvConnection* connection = [[TvConnection alloc] initWithTmdbId:teebee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
            
            if (code == WebserviceResultOk) {
                
                cell.notWatchedEpisodesLabel.hidden = YES;
                
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
            else {
                self.view.userInteractionEnabled = YES;
            }
        }];
        
        connection.activityIndicator = cell.activityIndicator;
        [self.connectionsManager startConnection:connection];
        
        self.view.userInteractionEnabled = NO;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        TeebeezHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"TeebeezHeaderView" forIndexPath:indexPath];

        if (indexPath.section >= TeebeezSection && indexPath.section < TeebeezSection + self.displayedTeebeez.count) {
            NSInteger section = indexPath.section - TeebeezSection;
            
            switch (section) {
                case TodaySection:
                    headerView.titleLabel.text = @"TODAY";
                    break;
                case TommorowSection:
                    headerView.titleLabel.text = @"TOMMOROW";
                    break;
                case ThisWeekSection:
                    headerView.titleLabel.text = @"THIS WEEK";
                    break;
                case SoonSection:
                    headerView.titleLabel.text = @"SOON";
                    break;
                    
                default:
                    break;
            }
        }
        
        return headerView;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (self.selectedType == TeebeeSoonType && section >= TeebeezSection && section < TeebeezSection + self.displayedTeebeez.count && [self.displayedTeebeez[section - TeebeezSection] count] > 0) {
        return CGSizeMake(320, 32);
    }

    return CGSizeMake(320, 0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if (self.selectedType == TeebeeSoonType && section >= TeebeezSection && section < TeebeezSection + self.displayedTeebeez.count) {
        if ([self.displayedTeebeez[section - TeebeezSection] count] == 0) {
            return UIEdgeInsetsMake(0, 12, 0, 12);
        }
        return UIEdgeInsetsMake(6, 12, 6, 12);
    }
    if (self.selectedType == TeebeeSoonType && section == 0) {
        return UIEdgeInsetsMake(13, 12, 20, 12);
    }
    
    return UIEdgeInsetsMake(13, 12, 13, 12);
    
}


#pragma mark - Animations

- (BeeCell*)animationCell {
    if (!_animationCell) {
        _animationCell = [[NSBundle mainBundle] loadNibNamed:@"BeeCell" owner:self options:nil][0];
    }
    return _animationCell;
}

- (void)hideMoobee:(Moobee*)moobee {
    
    int section = -1;
    NSInteger index = -1;
    for (int i = 0; i < self.displayedTeebeez.count; ++i) {
        index = [self.displayedTeebeez[i] indexOfObject:moobee];
        if (index != NSNotFound) {
            section = i;
            break;
        }
    }
    
    if (section == -1) {
        return;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:TeebeezSection + section];
 
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
    
    teebee.tvRageId = tv.tvRageId;
    teebee.backdropPath = tv.backdropPath;
    teebee.posterPath = tv.posterPath;
    
    TvViewController* viewController = [[TvViewController alloc] initWithNibName:@"TvViewController" bundle:nil];
    viewController.teebee = teebee;
    viewController.tmdbTv = tv;
    [self.navigationController pushViewController:viewController animated:NO];
    
    viewController.closeHandler = ^{
        
        if (teebee.id == -1) {
            if ([self.teebeez containsObject:teebee]) {
                [self.teebeez removeObject:teebee];
                [self applyFilter];
                [self.collectionView reloadData];
                [self.animationCell removeFromSuperview];
            }
            return;
        }
        
        if (self.selectedType == TeebeeToSeeType && teebee.notWatchedEpisodesCount == 0) {
            [self.teebeez removeObject:teebee];
            [self applyFilter];
            [self.collectionView reloadData];
            [self.animationCell removeFromSuperview];
            return;
        }
        
        // new moobee
        if (![self.teebeez containsObject:teebee]) {
            [self.teebeez addObject:teebee];
        }
        
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
    
    if (self.searchNewTvViewController.view.superview != nil)
    {
        return;
    }
    
    [self.appDelegate.window addSubview:self.searchNewTvViewController.view];
    
    __block TeebeezViewController *weakSelf = self;

    self.searchNewTvViewController.selectHandler = ^ (TmdbTV* tv) {
        
        Teebee* teebee = [Teebee teebeeWithTmdbTV:tv];
        
        weakSelf.view.userInteractionEnabled = NO;

        TvConnection* connection = [[TvConnection alloc] initWithTmdbId:teebee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
            if (code == WebserviceResultOk) {
                weakSelf.view.userInteractionEnabled = YES;
                [weakSelf.searchNewTvViewController.view removeFromSuperview];
                [weakSelf goToTvDetailsScreenForTeebee:teebee andTv:tv];
            }
        }];
        [weakSelf startConnection:connection];
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
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self applyFilter];
    [self reloadData];
}

#pragma mark - Update teebeez

- (void)updateTeebeez {
    
    self.numberOfTeebeezToUpdate = self.teebeezToUpdate.count;

    self.updatingView.frame = self.view.bounds;
    [LoadingView showLoadingViewWithContent:self.updatingView];

    [self updateNextTeebee];
}

- (void)updateNextTeebee {
    
    NSInteger updatedTeebeez = self.numberOfTeebeezToUpdate - self.teebeezToUpdate.count;
    
    self.updatingProgressBar.progress = (float)updatedTeebeez / self.numberOfTeebeezToUpdate;
    
    if (self.teebeezToUpdate.count) {
        Teebee* teebee = self.teebeezToUpdate[0];
        
        self.updatingLabel.text = [NSString stringWithFormat:@"Update teebeez... %ld/%ld", (long)updatedTeebeez + 1, (long)self.numberOfTeebeezToUpdate];

        [teebee updateEpisodesWithCompletion:^{
            [self.teebeezToUpdate removeObject:teebee];
            [self updateNextTeebee];
        }];
    }
    else {
        [self performSelector:@selector(endUpdate) withObject:nil afterDelay:0.1];
    }
}

- (void)endUpdate {
    [LoadingView hideLoadingView];
    self.isUpdating = NO;
}

@end
