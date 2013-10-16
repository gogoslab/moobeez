//
//  MoobeezViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MoobeezViewController.h"
#import "Moobeez.h"

@interface MoobeezViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* moobeezArray;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

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
    
    self.moobeezArray = [[Database sharedDatabase] moobeezWithType:MoobeeSeenType];
    
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.moobeezArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MoobeeCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoobeeCell" forIndexPath:indexPath];

    cell.moobee = self.moobeezArray[indexPath.row];
    
    return cell;
}


#pragma mark - Type

- (IBAction)typeSegmentedControlValueChanged:(id)sender {
    
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
    
    self.collectionView.contentOffset = CGPointZero;
    self.collectionView.contentSize = CGSizeZero;
    [self.collectionView reloadData];
    
}


@end
