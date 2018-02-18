//
//  ActorToolboxView.m
//  Moobeez
//
//  Created by Radu Banea on 11/05/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ActorToolboxView.h"
#import "Moobeez.h"

@interface ActorToolboxView () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *actorNameCell;
@property (weak, nonatomic) IBOutlet UILabel *actorNameLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *castCell;
@property (weak, nonatomic) IBOutlet UICollectionView *castCollectionView;

@property (strong, nonatomic) IBOutlet UITableViewCell *buttonsCell;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *castButton;
@property (weak, nonatomic) IBOutlet UIButton *photosButton;

@property (strong, nonatomic) NSMutableArray* cells;

@end

@implementation ActorToolboxView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self.castCollectionView registerNib:[UINib nibWithNibName:@"CharacterCellSmall" bundle:nil] forCellWithReuseIdentifier:@"CharacterCell"];
}

- (void)setTmdbPerson:(TmdbPerson *)tmdbPerson {

    _tmdbPerson = tmdbPerson;
    
    [self refreshToolbox];
}

- (void)refreshToolbox {

    self.cells = [[NSMutableArray alloc] init];
    
    [self.cells addObject:@[self.actorNameCell]];
    
    self.actorNameLabel.text = self.tmdbPerson.name;
    
    [self.cells addObject:@[self.castCell]];
    
    [self.cells addObject:@[self.buttonsCell]];
}

- (void)hideFullToolbox {
    [super hideFullToolbox];
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
    return [(UITableViewCell *) self.cells[indexPath.section][indexPath.row] height];
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
    return self.tmdbPerson.characters.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CharacterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CharacterCell" forIndexPath:indexPath];
    
    cell.character = self.tmdbPerson.characters[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CharacterCell* cell = (CharacterCell*) [collectionView cellForItemAtIndexPath:indexPath];
    
    self.characterSelectionHandler(self.tmdbPerson.characters[indexPath.row], cell);
}

#pragma mark - Buttons

- (void)setIsLightInterface:(BOOL)isLightInterface {
    super.isLightInterface = isLightInterface;

    UIColor* textsColor = (self.isLightInterface ? [UIColor whiteColor] : [UIColor blackColor]);
    
    self.actorNameLabel.textColor = textsColor;
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:(self.isLightInterface ? @"MovieButtonsWhite" : @"MovieButtonsBlack") ofType:@"bundle"]];
    
    [self.descriptionButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:ResourceName(@"button_description") ofType:@"png"]] forState:UIControlStateNormal];
    [self.castButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:ResourceName(@"button_cast") ofType:@"png"]] forState:UIControlStateNormal];
    [self.photosButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:ResourceName(@"button_photos") ofType:@"png"]] forState:UIControlStateNormal];
}
@end
