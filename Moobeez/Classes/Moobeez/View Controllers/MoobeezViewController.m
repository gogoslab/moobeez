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
    SectionsCount
    };

@interface MoobeezViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* moobeezArray;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (strong, nonatomic) UICollectionViewCell *searchCell;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (readwrite, nonatomic) CGFloat initialCollectionViewHeight;

@property (strong, nonatomic) MoobeeCell* animationCell;

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
    
    self.collectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);

    [self.collectionView registerNib:[UINib nibWithNibName:@"MoobeeCell" bundle:nil] forCellWithReuseIdentifier:@"MoobeeCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SearchCell"];
    
    self.moobeezArray = [[Database sharedDatabase] moobeezWithType:MoobeeSeenType];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMoobeez) name:DatabaseDidReloadNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    static BOOL firstAppear = YES;
    
    if (firstAppear) {
        self.initialCollectionViewHeight = self.collectionView.height;

        [self reloadData];
    
        self.collectionView.contentOffset = CGPointMake(0, 6);
        firstAppear = NO;
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

- (void)reloadMoobeez {
    
    switch (self.typeSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.moobeezArray = [[Database sharedDatabase] moobeezWithType:MoobeeSeenType];
            break;
        case 1:
            self.moobeezArray = [[Database sharedDatabase] moobeezWithType:MoobeeOnWatchlistType];
            break;
        case 2:
            self.moobeezArray = [[Database sharedDatabase] favoritesMoobeez];
            break;
        default:
            break;
    }
    
    [self reloadData];
    
    self.collectionView.contentOffset = CGPointMake(0, -60);
    
}

- (void)reloadData {

    [self.collectionView reloadData];
    
    self.collectionView.height = MIN(self.collectionView.collectionViewLayout.collectionViewContentSize.height, self.initialCollectionViewHeight);
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
            return self.moobeezArray.count;
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
    
    MoobeeCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoobeeCell" forIndexPath:indexPath];

    cell.moobee = self.moobeezArray[indexPath.row];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SearchSection) {
        
        return CGSizeMake(296, 10);
        
    }
    
    return CGSizeMake(90, [MoobeeCell cellHeight]);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MoobeezSection) {
        
        MoobeeCell* cell = (MoobeeCell*) [collectionView cellForItemAtIndexPath:indexPath];
        
        Moobee* moobee = self.moobeezArray[indexPath.row];
        
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            if (!self.animationCell) {
                self.animationCell = [[NSBundle mainBundle] loadNibNamed:@"MoobeeCell" owner:self options:nil][0];
            }
            
            [self.view addSubview:self.animationCell];
            self.animationCell.frame = [self.view convertRect:cell.frame fromView:cell.superview];
            
            self.animationCell.moobee = moobee;
            
            [self.animationCell animateGrowWithCompletion:^{
                MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
                viewController.moobee = moobee;
                viewController.tmdbMovie = movie;
                [self presentViewController:viewController animated:NO completion:^{}];
                
                viewController.closeHandler = ^{
                    [moobee save];
                    
                    [self.moobeezArray sortUsingSelector:@selector(compareByDate:)];
                    
                    [self.collectionView reloadData];
                    
                    self.animationCell.moobee = moobee;
                    [self.animationCell prepareForShrink];

                    [self performSelector:@selector(hideMoobee:) withObject:moobee afterDelay:0.01];
                };
                
                [self.animationCell removeFromSuperview];
            }];
        }];
        
        connection.activityIndicator = cell.activityIndicator;
        [self.connectionsManager startConnection:connection];
    }
}

- (void)hideMoobee:(Moobee*)moobee {
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.moobeezArray indexOfObject:moobee] inSection:MoobeezSection];
 
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


#pragma mark - Type

- (IBAction)typeSegmentedControlValueChanged:(id)sender {
    
    [self reloadMoobeez];

}


@end
