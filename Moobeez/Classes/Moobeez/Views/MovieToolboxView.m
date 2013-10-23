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

@property (strong, nonatomic) NSMutableArray* cells;

@end

@implementation MovieToolboxView

- (void)awakeFromNib {
    
    [self.castCollectionView registerNib:[UINib nibWithNibName:@"CharacterCell" bundle:nil] forCellWithReuseIdentifier:@"CharacterCell"];
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
    
    [self.cells addObject:self.movieNameCell];
    
    self.movieNameTextField.text = (self.moobee ? self.moobee.name : self.tmdbMovie.name);
    
    if (self.moobee.date) {
        [self.cells addObject:self.starsCell];
        self.starsView.rating = self.moobee.rating;
        
        [self.cells addObject:self.seenDateCell];
        self.seenDateLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"dd MMMM yyyy"] stringFromDate:self.moobee.date];
    }
    
    if (self.tmdbMovie) {
        [self.cells addObject:self.castCell];
        [self.castCollectionView reloadData];
    }

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cells[indexPath.row] height];
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

@end
