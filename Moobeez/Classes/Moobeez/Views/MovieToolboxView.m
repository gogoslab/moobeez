//
//  MovieToolboxView.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieToolboxView.h"
#import "Moobeez.h"

@interface MovieToolboxView () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *movieNameCell;
@property (weak, nonatomic) IBOutlet UITextField *movieNameTextField;

@property (strong, nonatomic) IBOutlet UITableViewCell *starsCell;
@property (weak, nonatomic) IBOutlet StarsView *starsView;

@property (strong, nonatomic) IBOutlet UITableViewCell *seenDateCell;
@property (weak, nonatomic) IBOutlet UILabel *seenDateLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *castCell;
@property (weak, nonatomic) IBOutlet UICollectionView *castCollectionView;

@property (strong, nonatomic) IBOutlet UITableViewCell *buttonsCell;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *castButton;
@property (weak, nonatomic) IBOutlet UIButton *photosButton;
@property (weak, nonatomic) IBOutlet UIButton *trailerButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;

@property (strong, nonatomic) IBOutlet UITableViewCell *typeButtonsCell;
@property (weak, nonatomic) IBOutlet UIButton *watchlistButton;
@property (weak, nonatomic) IBOutlet UIButton *sawButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *watchlistLabels;


@property (strong, nonatomic) NSMutableArray* cells;

@end

@implementation MovieToolboxView

- (void)awakeFromNib {
    
    [self.castCollectionView registerNib:[UINib nibWithNibName:@"CharacterCellSmall" bundle:nil] forCellWithReuseIdentifier:@"CharacterCell"];
    
    self.starsView.updateHandler = ^{ self.moobee.rating = self.starsView.rating; };
}

- (void)setMoobee:(Moobee *)moobee {

    _moobee = moobee;
    
    [self refreshToolbox];
}

- (void)setTmdbMovie:(TmdbMovie *)tmdbMovie {

    _tmdbMovie = tmdbMovie;
    
    [self refreshToolbox];
}

- (void)refreshToolbox {

    self.cells = [[NSMutableArray alloc] init];
    
    [self.cells addObject:@[self.movieNameCell]];
    
    self.movieNameTextField.text = (self.moobee ? self.moobee.name : self.tmdbMovie.name);
    
    if (self.moobee.type == MoobeeSeenType) {
        [self.cells addObject:@[self.starsCell, self.seenDateCell]];

        self.starsView.rating = self.moobee.rating;
        
        self.seenDateLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"dd MMMM yyyy"] stringFromDate:self.moobee.date];
    }
    else {
        [self.cells addObject:@[self.typeButtonsCell]];
        [self refreshWatchlistButton];
    }
    
    if (self.tmdbMovie) {
        [self.cells addObject:@[self.castCell]];
        [self.castCollectionView reloadData];
    }
    
    [self.cells addObject:@[self.buttonsCell]];

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cells[section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.section][indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cells[indexPath.section][indexPath.row] height];
}

#pragma mark - Text Field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.y > self.minToolboxY) {
        [self showFullToolbox];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tmdbMovie.characters.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CharacterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CharacterCell" forIndexPath:indexPath];
    
    cell.character = self.tmdbMovie.characters[indexPath.row];
    
    return cell;
}

#pragma mark - Buttons

- (IBAction)watchButtonPressed:(id)sender {
    self.moobee.type = (!self.watchlistButton.selected ? MoobeeOnWatchlistType : MoobeeNoneType);
    
    [self refreshWatchlistButton];
}

- (void)refreshWatchlistButton {
    self.watchlistButton.selected = (self.moobee.type == MoobeeOnWatchlistType);
    
    NSString* title = (self.watchlistButton.selected ? @"remove from watchlist" : @"add to watchlist");
    
    NSArray* titles = [title componentsSeparatedByString:@" "];
    
    [self.watchlistLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UILabel*) obj).text = titles[idx];
    }];
}

- (IBAction)sawButtonPressed:(id)sender {
    self.moobee.type = MoobeeSeenType;
    
    [self.cells replaceObjectAtIndex:1 withObject:@[self.starsCell, self.seenDateCell]];
    
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (IBAction)descriptionButtonPressed:(id)sender {
}

- (IBAction)castButtonPressed:(id)sender {
}

- (IBAction)photosButtonPressed:(id)sender {
}

- (IBAction)trailerButtonPressed:(id)sender {
}

- (IBAction)favoritesButtonPressed:(id)sender {
    self.moobee.isFavorite = !self.moobee.isFavorite;
    self.favoritesButton.selected = self.moobee.isFavorite;
}
@end
