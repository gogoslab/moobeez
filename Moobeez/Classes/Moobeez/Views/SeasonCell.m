//
//  SeasonCell.m
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SeasonCell.h"
#import "Moobeez.h"

@interface SeasonCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (weak, nonatomic) IBOutlet UILabel *episodesLabel;

@property (weak, nonatomic) IBOutlet UIButton *watchButton;
@end

@implementation SeasonCell

- (void)awakeFromNib {
    self.posterImageView.loadSyncronized = YES;
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MovieButtonsBlack" ofType:@"bundle"]];
    [self.watchButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected" ofType:@"png"]] forState:UIControlStateSelected];


}

- (void)setNumberOfEpisodesWatched:(NSNumber *)numberOfEpisodesWatched {
    _numberOfEpisodesWatched = numberOfEpisodesWatched;
    
    [self refreshEpisodesLabel];
    
    self.watchButton.selected = [numberOfEpisodesWatched integerValue] > 0;
}

- (void)setSeason:(TmdbTvSeason *)season {

    _season = season;
    
    [self.posterImageView loadImageWithPath:season.posterPath andWidth:92 completion:^(BOOL didLoadImage) {}];
    self.titleLabel.text = season.name;

    [self refreshEpisodesLabel];
    
    if (season.description) {
        self.detailsLabel.text = season.description;
    }
    else {
        self.detailsLabel.text = @"";
    }
    
    if (season.episodes) {
        self.watchButton.enabled = self.season.episodes.count > 0;
    }

    self.detailsLabel.hidden = (self.detailsLabel.text.length == 0);
}

- (void)refreshEpisodesLabel {
    if (self.season.episodes) {
        
        NSAttributedString* allEpisodesString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)self.season.episodes.count] attributes:@{NSForegroundColorAttributeName : [UIColor mainColor]}];
        
        if (self.numberOfEpisodesWatched) {
            
            NSAttributedString* watchedEpisodesString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [self.numberOfEpisodesWatched intValue]] attributes:@{NSForegroundColorAttributeName : [UIColor mainColor]}];
            
            NSMutableAttributedString* episodesString = [[NSMutableAttributedString alloc] init];
            [episodesString appendAttributedString:watchedEpisodesString];
            [episodesString appendAttributedString:[[NSAttributedString alloc] initWithString:@" / " attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}]];
            [episodesString appendAttributedString:allEpisodesString];
            [episodesString appendAttributedString:[[NSAttributedString alloc] initWithString:@" episodes watched" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}]];
            
            self.episodesLabel.attributedText = episodesString;
        }
        else {
            
            NSMutableAttributedString* episodesString = [[NSMutableAttributedString alloc] init];
            [episodesString appendAttributedString:allEpisodesString];
            [episodesString appendAttributedString:[[NSAttributedString alloc] initWithString:@" episodes" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}]];
            
            self.episodesLabel.attributedText = episodesString;
        }
    }
    else {
        self.episodesLabel.text = @"";
    }
}

- (IBAction)watchButtonPressed:(id)sender {
    
    if (!self.watchButton.selected) {
        [Alert showAlertViewWithTitle:@"Attention" message:[NSString stringWithFormat:@"This action will mark all the episodes that aired in season %ld as \"Watched\", are you sure?", (long)self.season.seasonNumber] buttonClickedCallback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
                if ([[Database sharedDatabase] watchAllEpisodes:YES forTeebee:self.teebee inSeason:self.season.seasonNumber]) {
                    [[Database sharedDatabase] pullTeebeezEpisodesCount:self.teebee];
                    [[Database sharedDatabase] pullSeasonsForTeebee:self.teebee];
                    self.numberOfEpisodesWatched = self.teebee.seasons[StringId(self.season.seasonNumber)];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateWatchedEpisodesNotification object:self.teebee];
                }
                else {
                    [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to update the database, please try again" buttonClickedCallback:^(NSInteger buttonIndex) {} cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                }
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    else {
        [Alert showAlertViewWithTitle:@"Attention" message:[NSString stringWithFormat:@"This action will mark all the episodes that aired in season %ld as \"Not watched\", are you sure?", (long)self.season.seasonNumber] buttonClickedCallback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if ([[Database sharedDatabase] watchAllEpisodes:NO forTeebee:self.teebee inSeason:self.season.seasonNumber]) {
                    [[Database sharedDatabase] pullTeebeezEpisodesCount:self.teebee];
                    [[Database sharedDatabase] pullSeasonsForTeebee:self.teebee];
                    self.numberOfEpisodesWatched = self.teebee.seasons[StringId(self.season.seasonNumber)];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateWatchedEpisodesNotification object:self.teebee];
                }
                else {
                    [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to update the database, please try again" buttonClickedCallback:^(NSInteger buttonIndex) {} cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                }
                
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
}

@end
