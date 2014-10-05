//
//  DashboardTvShowCell.m
//  Moobeez
//
//  Created by Radu Banea on 01/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "DashboardTvShowCell.h"
#import "Moobeez.h"
#import "ImageView.h"

@interface DashboardTvShowCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchedButton;

@end

@implementation DashboardTvShowCell

- (void)awakeFromNib
{
    // Initialization code
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MovieButtonsWhite" ofType:@"bundle"]];
    
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected@2x" ofType:@"png"]] forState:UIControlStateSelected];
    
}

- (void)setTvShowDictionary:(NSMutableDictionary *)tvShowDictionary {
    _tvShowDictionary = tvShowDictionary;
    
    self.nameLabel.text = tvShowDictionary[@"name"];
    
    self.detailsLabel.text = [NSString stringWithFormat:@"Season %d Episode %d", [tvShowDictionary[@"seasonNumber"] intValue], [tvShowDictionary[@"episodeNumber"] intValue]];
    
    [self.posterImageView loadPosterWithPath:tvShowDictionary[@"posterPath"] completion:^(BOOL didLoadImage) {
        
    }];
    
//    NSURL *imageURL = [NSURL URLWithString:tvShowDictionary[@"posterFullPath"]];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Update the UI
//            self.posterImageView.image = [UIImage imageWithData:imageData];
//        });
//    });
    
}

- (IBAction)watchButtonPressed:(id)sender {
    
    if ([self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:[self.parentTableView indexPathForCell:self]];
    }
}
@end
