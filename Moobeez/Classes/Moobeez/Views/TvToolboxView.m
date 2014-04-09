//
//  TvToolboxView.m
//  Teebeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TvToolboxView.h"
#import "Moobeez.h"

@interface TvToolboxView () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *movieNameCell;
@property (weak, nonatomic) IBOutlet UITextField *movieNameTextField;

@property (strong, nonatomic) IBOutlet UITableViewCell *starsCell;
@property (weak, nonatomic) IBOutlet StarsView *starsView;

@property (strong, nonatomic) IBOutlet UITableViewCell *statusCell;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *episodesCell;
@property (weak, nonatomic) IBOutlet UILabel *seasonsLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodesLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *castCell;
@property (weak, nonatomic) IBOutlet UICollectionView *castCollectionView;

@property (strong, nonatomic) IBOutlet UITableViewCell *buttonsCell;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *castButton;
@property (weak, nonatomic) IBOutlet UIButton *photosButton;
@property (weak, nonatomic) IBOutlet UIButton *episodesButton;
@property (weak, nonatomic) IBOutlet UIButton *watchedButton;

@property (strong, nonatomic) NSMutableArray* cells;

@property (strong, nonatomic) TeebeeEpisode* nextEpisodeToWatch;

@end

@implementation TvToolboxView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self.castCollectionView registerNib:[UINib nibWithNibName:@"CharacterCellSmall" bundle:nil] forCellWithReuseIdentifier:@"CharacterCell"];
    
    self.starsView.updateHandler = ^{ self.teebee.rating = self.starsView.rating; };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEpisodesSection) name:DidUpdateWatchedEpisodesNotification object:self.teebee];

}

- (void)setTeebee:(Teebee *)teebee {

    _teebee = teebee;
    
    [self refreshToolbox];
}

- (void)setTmdbTv:(TmdbTV *)tmdbTv {

    _tmdbTv = tmdbTv;
    
    [self refreshToolbox];
}

- (void)refreshToolbox {
    
    self.cells = [[NSMutableArray alloc] init];
    
    [self.cells addObject:@[self.movieNameCell]];
    
    self.movieNameTextField.text = (self.teebee ? self.teebee.name : self.tmdbTv.name);
    
    [self.cells addObject:@[self.statusCell]];
    
    if (self.teebee.watchedEpisodesCount == 0) {
        [self.cells addObject:@[self.episodesCell]];
    }
    else {
        [self.cells addObject:@[self.starsCell]];
    }

    self.episodesLabel.text = [NSString stringWithFormat:@"%ld episodes", (long)self.tmdbTv.episodesCount];
    self.seasonsLabel.text = [NSString stringWithFormat:@"%ld seasons", (long)self.tmdbTv.seasonsCount];
    
    [self refreshTeebeeInfo];
    
    if (self.tmdbTv) {
        [self.cells addObject:@[self.castCell]];
        [self.castCollectionView reloadData];
    }
    
    [self.cells addObject:@[self.buttonsCell]];
    
    self.watchedButton.selected = self.teebee.watchedEpisodesCount > 0;
}

- (void)refreshTeebeeInfo {
    if (self.teebee.rating >= 0) {
        self.starsView.rating = self.teebee.rating;
    }
    
    if (self.teebee.watchedEpisodesCount == 0) {
        self.statusLabel.text = @"Not watched";
    }
    else {
        if (self.tmdbTv.inProduction) {
            self.nextEpisodeToWatch = [[Database sharedDatabase] nextEpisodeToWatchForTeebee:self.teebee];
            
            if (!self.nextEpisodeToWatch.airDate) {
                self.statusLabel.text = @"In progress";
            }
            else {
                NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setMinimumIntegerDigits:2];
                self.statusLabel.text = [NSString stringWithFormat:@"Next episode to watch: E%@/S%@", [numberFormatter stringFromNumber:@(self.nextEpisodeToWatch.episodeNumber)], [numberFormatter stringFromNumber:@(self.nextEpisodeToWatch.seasonNumber)]];
                if ([self.nextEpisodeToWatch.airDate timeIntervalSinceNow] > 0){
                    self.statusLabel.text = [self.statusLabel.text stringByAppendingFormat:@" on %@", [[NSDateFormatter dateFormatterWithFormat:@"dd MMM"] stringFromDate:self.nextEpisodeToWatch.airDate]];
                }
            }
        }
        else {
            self.statusLabel.text = @"Finished";
        }
    }
    
}

- (void)hideFullToolbox {
    [super hideFullToolbox];
    [self.movieNameTextField resignFirstResponder];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return self.tmdbTv.characters.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CharacterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CharacterCell" forIndexPath:indexPath];
    
    cell.character = self.tmdbTv.characters[indexPath.row];
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.characterSelectionHandler(self.tmdbTv.characters[indexPath.row], (CharacterCell*) [collectionView cellForItemAtIndexPath:indexPath]);
    
}

#pragma mark - Buttons

- (IBAction)watchedButtonPressed:(id)sender {
    
    if (!self.watchedButton.selected) {
        [Alert showAlertViewWithTitle:@"Attention" message:@"This action will mark all the episodes that aired as \"Watched\", are you sure?" buttonClickedCallback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (self.teebee.id == -1) {
                    BOOL didAddShowToDatabase = [self.teebee addTeebeeToDatabaseWithCompletion:^{
                        [self watchAllEpisodes];
                    }];
                    if (!didAddShowToDatabase)
                    {
                        [Alert showDatabaseUpdateErrorAlert];
                    }
                }
                else {
                    [self watchAllEpisodes];
                }
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    else {
        [Alert showAlertViewWithTitle:@"Attention" message:@"This action will mark all the episodes that aired as \"Not watched\", are you sure?" buttonClickedCallback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if ([[Database sharedDatabase] watchAllEpisodes:NO forTeebee:self.teebee]) {
                    [[Database sharedDatabase] pullTeebeezEpisodesCount:self.teebee];
                    [[Database sharedDatabase] pullSeasonsForTeebee:self.teebee];

                    [self updateEpisodesSection];
                }
                else {
                    [Alert showDatabaseUpdateErrorAlert];
                }
                
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
}

- (void)watchAllEpisodes {
    
    if ([[Database sharedDatabase] watchAllEpisodes:YES forTeebee:self.teebee])
    {
        [[Database sharedDatabase] pullTeebeezEpisodesCount:self.teebee];
        [[Database sharedDatabase] pullSeasonsForTeebee:self.teebee];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateWatchedEpisodesNotification object:self.teebee];
    }
    else {
        [Alert showDatabaseUpdateErrorAlert];
    }
}


- (void)setIsLightInterface:(BOOL)isLightInterface {
    super.isLightInterface = isLightInterface;
    
    UIColor* textsColor = (self.isLightInterface ? [UIColor whiteColor] : [UIColor blackColor]);
    
    self.movieNameTextField.textColor = textsColor;
    self.statusLabel.textColor = textsColor;
    self.seasonsLabel.textColor = textsColor;
    self.episodesLabel.textColor = textsColor;
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:(self.isLightInterface ? @"MovieButtonsWhite" : @"MovieButtonsBlack") ofType:@"bundle"]];
    
    [self.descriptionButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_description" ofType:@"png"]] forState:UIControlStateNormal];
    [self.castButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_cast" ofType:@"png"]] forState:UIControlStateNormal];
    [self.photosButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_photos" ofType:@"png"]] forState:UIControlStateNormal];
    [self.episodesButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_episodes" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected" ofType:@"png"]] forState:UIControlStateSelected];
    
    self.starsView.emptyStarsImageView.highlighted = self.isLightInterface;

}

- (void)updateEpisodesSection {
    
    BOOL showWatched = self.teebee.watchedEpisodesCount > 0;
    
    [self refreshTeebeeInfo];
    
    if (self.watchedButton.selected == showWatched) {
        return;
    }
    
    self.watchedButton.selected = showWatched;
    if (showWatched && self.teebee.rating < 0) {
        self.teebee.rating = 2.5;
    }
    if (!showWatched) {
        self.teebee.rating = -1;
    }
    
    if (!showWatched) {
        [self.cells replaceObjectAtIndex:2 withObject:@[self.episodesCell]];
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else {
        
        [self.cells replaceObjectAtIndex:2 withObject:@[self.starsCell]];
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

    }
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidUpdateWatchedEpisodesNotification object:self.teebee];
    
}
@end
