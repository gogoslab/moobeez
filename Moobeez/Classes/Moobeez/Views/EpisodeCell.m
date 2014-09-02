//
//  EpisodeCell.m
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "EpisodeCell.h"
#import "Moobeez.h"

@interface EpisodeCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *watchButton;
@end

@implementation EpisodeCell

- (void)awakeFromNib {
    self.posterImageView.loadSyncronized = YES;
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MovieButtonsBlack" ofType:@"bundle"]];
    [self.watchButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected@2x" ofType:@"png"]] forState:UIControlStateSelected];


}

- (void)setEpisode:(TmdbTvEpisode *)episode {

    _episode = episode;
    
    [self.posterImageView loadImageWithPath:episode.posterPath andWidth:92 completion:^(BOOL didLoadImage) {}];
    self.titleLabel.text = episode.name;
    self.episodeLabel.text = StringInteger((long)episode.episodeNumber);

    if (episode.overview) {
        self.detailsLabel.text = episode.overview;
    }
    else {
        self.detailsLabel.text = @"";
    }
    self.detailsLabel.hidden = (self.detailsLabel.text.length == 0);
    
    self.dateLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"dd MMMM yyyy"] stringFromDate:self.episode.date];
}

- (void)setTeebeeEpisode:(TeebeeEpisode *)teebeeEpisode {

    _teebeeEpisode = teebeeEpisode;
    
    self.watchButton.selected = self.teebeeEpisode.watched;
}

- (IBAction)watchButtonPressed:(id)sender {
    
    if (!self.watchButton.selected) {
        
        if (self.teebee.id == -1) {
            BOOL didAddShowToDatabase = [self.teebee addTeebeeToDatabaseWithCompletion:^{
                [self watchEpisode];
            }];

            if (!didAddShowToDatabase)
            {
                [Alert showDatabaseUpdateErrorAlert];
            }
        }
        else {
            [self watchEpisode];
        }
    }
    else {
        if ([[Database sharedDatabase] watch:NO episode:self.teebeeEpisode forTeebee:self.teebee]) {
            self.teebee.watchedEpisodesCount--;
            self.teebee.notWatchedEpisodesCount++;
            self.teebee.seasons[StringInteger((long)self.teebeeEpisode.seasonNumber)] = @([self.teebee.seasons[StringInteger((long)self.teebeeEpisode.seasonNumber)] integerValue] - 1);
            
            self.watchButton.selected = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateWatchedEpisodesNotification object:self.teebee];
        }
        else {
            [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to update the database, please try again" buttonClickedCallback:^(NSInteger buttonIndex) {} cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        }
    }
}

- (void)watchEpisode {
    
    if ([[Database sharedDatabase] watch:YES episode:self.teebeeEpisode forTeebee:self.teebee])
    {
        self.teebee.watchedEpisodesCount++;
        self.teebee.notWatchedEpisodesCount--;
        self.teebee.seasons[StringInteger((long)self.teebeeEpisode.seasonNumber)] = @([self.teebee.seasons[StringInteger((long)self.teebeeEpisode.seasonNumber)] integerValue] + 1);
        
        self.watchButton.selected = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateWatchedEpisodesNotification object:self.teebee];
    }
    else {
        [Alert showDatabaseUpdateErrorAlert];
    }
}


@end
