//
//  MoviesViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MoviesViewController.h"
#import "Moobeez.h"

typedef enum MoviesSection {
    SectionNowPlaying = 0,
    SectionUpcomingType,
    SectionPopularType,
    SectionTopRatedType,
    SectionsCount
    } MoviesSection;

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray* featuredCells;
@property (strong, nonatomic) NSMutableArray* expandedSections;

@property (strong, nonatomic) NSMutableArray* headersViews;

@property (strong, nonatomic) NSArray* sectionsTitles;

@property (strong, nonatomic) FeatureMoviesCell* panningCell;

@property (strong, nonatomic) MoviePosterView* animatedPosterView;
@property (readwrite, nonatomic) NSInteger selectedSection;

@end

@implementation MoviesViewController

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
    
    self.sectionsTitles = @[@"NOW PLAYING", @"UPCOMING", @"POPULAR", @"TOP RATED"];
    
    self.featuredCells = [[NSMutableArray alloc] init];
    self.expandedSections = [[NSMutableArray alloc] init];
    self.headersViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < SectionsCount; ++i) {
        FeatureMoviesCell* cell = [[NSBundle mainBundle] loadNibNamed:@"FeatureMoviesCell" owner:self options: nil][0];
        cell.height = [MoviePosterView height];
        cell.titleLabel.text = self.sectionsTitles[i];
        cell.isReverse = (i % 2 == 1);
        cell.parentTableView = self.tableView;
        [self.featuredCells addObject:cell];
        [self loadMoviesWithType:i inSection:i];
        [self.expandedSections addObject:@NO];
        
        MoviesHeaderView* headerView = [[NSBundle mainBundle] loadNibNamed:@"MoviesHeaderView" owner:self options:nil][0];
        headerView.titleLabel.text = self.sectionsTitles[i];
        headerView.collapseButton.tag = i;
        [self.headersViews addObject:headerView];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    [self.tableView reloadData];
    
    self.animatedPosterView = [[NSBundle mainBundle] loadNibNamed:@"MoviePosterView" owner:self options:nil][0];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    for (int i = 0; i < SectionsCount; ++i) {
        if ([self.tableView indexPathForCell:self.featuredCells[i]] && i != self.selectedSection) {
            [self.featuredCells[i] startAnimating];
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {

    for (int i = 0; i < SectionsCount; ++i) {
        [self.featuredCells[i] stopAnimating];
    }
    
}

- (void)loadMoviesWithType:(MoviesListType)moviesType inSection:(MoviesSection)section {
    
    MoviesListConnection* connection = [[MoviesListConnection alloc] initWithType:moviesType completionHandler:^(WebserviceResultCode code, NSMutableArray *movies) {
        if (code == WebserviceResultOk) {
            [self.featuredCells[section] setMovies:movies];
            if ([self.tableView indexPathForCell:self.featuredCells[section]]) {
                [self.featuredCells[section] performSelector:@selector(startAnimating) withObject:nil afterDelay:section * 0.3];
            }
        }
    }];
    
    [self startConnection:connection];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return SectionsCount;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([self.expandedSections[section] boolValue] ? ((FeatureMoviesCell*) self.featuredCells[section]).movies.count : 1);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.expandedSections[indexPath.section] boolValue]) {
        
        NSArray* movies = ((FeatureMoviesCell*) self.featuredCells[indexPath.section]).movies;
        
        MovieCell* cell = (MovieCell*) [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
        
        cell.movie = movies[indexPath.row];
        
        return cell;
        
    }
    else {
        return self.featuredCells[indexPath.section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandedSections[indexPath.section] boolValue]) {
        
        return 120;
        
    }
    else {
        return [self.featuredCells[indexPath.section] height];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headersViews[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([self.expandedSections[section] boolValue]) {
        return [self.headersViews[section] height];
    }
    
    return 0.0;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    
    self.expandedSections[indexPath.section] = @YES;
    
    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    [tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[FeatureMoviesCell class]]) {
        [(FeatureMoviesCell*) cell startAnimating];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[FeatureMoviesCell class]]) {
        [(FeatureMoviesCell*) cell stopAnimating];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoviePosterView* posterView = nil;
    if (![self.expandedSections[indexPath.section] boolValue]) {
        posterView = [self.featuredCells[indexPath.section] posterViewWithIndex:indexPath.row];
    }
    else {
        posterView = ((MovieCell*) [tableView cellForRowAtIndexPath:indexPath]).posterView;
    }
    
    if (posterView) {
        
        [self.featuredCells[indexPath.section] stopAnimating];
        
        self.animatedPosterView.frame = [self.view convertRect:posterView.frame fromView:posterView.superview];
        self.animatedPosterView.movie = posterView.movie;
        
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:posterView.movie.id completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            
            if (code == WebserviceResultOk) {
                self.selectedSection = indexPath.section;
                
                [self.view addSubview:self.animatedPosterView];
                
                [self.animatedPosterView animateGrowWithCompletion:^{
                    
                    self.view.userInteractionEnabled = YES;
                    
                    Moobee* moobee = [Moobee moobeeWithTmdbMovie:posterView.movie];
                    
                    if (moobee.id == -1) {
                        moobee.type = MoobeeNoneType;
                    }
                    
                    [self goToMovieDetailsScreenForMoobee:moobee andMovie:movie];
                }];
            }
        }];
        
        connection.activityIndicator = posterView.activityIndicator;
        [self.connectionsManager startConnection:connection];
    }

}

- (void)goToMovieDetailsScreenForMoobee:(Moobee*)moobee andMovie:(TmdbMovie*)movie {
    
    MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
    viewController.moobee = moobee;
    viewController.tmdbMovie = movie;
    [self presentViewController:viewController animated:NO completion:^{}];
    
    viewController.closeHandler = ^{
        
        [self.animatedPosterView prepareForShrink];
        
        [self performSelector:@selector(hidePosterView) withObject:nil afterDelay:0.01];
    };
}

- (void)hidePosterView {
    [self.animatedPosterView animateShrinkWithCompletion:^{
        [self.animatedPosterView removeFromSuperview];
        if (self.selectedSection > -1 && [self.tableView indexPathForCell:self.featuredCells[self.selectedSection]]) {
            [self.featuredCells[self.selectedSection] startAnimating];
        }
        self.selectedSection = -1;
    }];
}

#pragma mark - Pann

- (IBAction)didPanned:(id)sender {
    
    UIPanGestureRecognizer* reconizer = (UIPanGestureRecognizer*) sender;
    
    if (reconizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [reconizer locationInView:self.tableView];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
        
        if ([cell isKindOfClass:[FeatureMoviesCell class]]) {
            self.panningCell = (FeatureMoviesCell*) cell;
        }
    }
    
    if (self.panningCell) {
        [self.panningCell didPanned:sender];
    }

    if (reconizer.state == UIGestureRecognizerStateCancelled || reconizer.state == UIGestureRecognizerStateEnded || reconizer.state == UIGestureRecognizerStateFailed) {
        self.panningCell = nil;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Only accept horizontal pans here.
    // Leave the vertical pans for scrolling the content.
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer translationInView:self.tableView];
        BOOL isHorizontalPan = (fabsf(translation.x) > fabsf(translation.y));
        return  isHorizontalPan;
    }

    return YES;
}

#pragma mark - Collapse

- (IBAction)collapseButtonPressed:(id)sender {
    
    NSInteger section = ((UIButton*) sender).tag;
    
    [self.tableView beginUpdates];
    
    self.expandedSections[section] = @NO;
    
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];

}

@end
