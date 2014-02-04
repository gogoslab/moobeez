//
//  TVsViewController.m
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TVsViewController.h"
#import "Moobeez.h"

typedef enum TVsSection {
    SectionOnTheAir = 0,
    SectionPopularType,
    SectionTopRatedType,
    SectionsCount
    } TVsSection;

@interface TVsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray* featuredCells;
@property (strong, nonatomic) NSMutableArray* expandedSections;

@property (strong, nonatomic) NSMutableArray* headersViews;

@property (strong, nonatomic) NSArray* sectionsTitles;

@property (strong, nonatomic) FeatureMoviesCell* panningCell;

@property (strong, nonatomic) MoviePosterView* animatedPosterView;
@property (readwrite, nonatomic) NSInteger selectedSection;

@end

@implementation TVsViewController

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
    
    self.sectionsTitles = @[@"ON THE AIR", @"POPULAR", @"TOP RATED"];
    
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

- (void)loadMoviesWithType:(TVsListType)tvsType inSection:(TVsSection)section {
    
    TVsListConnection* connection = [[TVsListConnection alloc] initWithType:tvsType completionHandler:^(WebserviceResultCode code, NSMutableArray *tvs) {
        if (code == WebserviceResultOk) {
            [self.featuredCells[section] setMovies:tvs];
            if ([self.tableView indexPathForCell:self.featuredCells[section]]) {
                [self.featuredCells[section] performSelector:@selector(startAnimating) withObject:nil afterDelay:section * 0.3];
            }
            [self.tableView reloadData];
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
    
    NSInteger moviesCount = ((FeatureMoviesCell*) self.featuredCells[section]).movies.count;
    
    if (moviesCount) {
        return ([self.expandedSections[section] boolValue] ? moviesCount : 1);
    }
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.expandedSections[indexPath.section] boolValue]) {
        
        NSArray* movies = ((FeatureMoviesCell*) self.featuredCells[indexPath.section]).movies;
        
        MovieCell* cell = (MovieCell*) [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
        
        cell.parentTableView = tableView;
        
        cell.movie = movies[indexPath.row];
        
        return cell;
        
    }
    else {
        return self.featuredCells[indexPath.section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandedSections[indexPath.section] boolValue]) {
        
        CGFloat rowHeight = 120;
        
        if (indexPath.row == 0) {
            return rowHeight + 41;
        }
        
        return rowHeight;
        
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
        return 1;//[self.headersViews[section] height];
    }
    
    return 0.0;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    
    [tableView beginUpdates];
    
    self.expandedSections[indexPath.section] = @(![self.expandedSections[indexPath.section] boolValue]);
    
    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    [tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    
    
    if (![self.expandedSections[indexPath.section] boolValue]) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//        NSIndexPath topIndexPath = [tableView indexPathForCell:[tableView visibleCells][0]];
//        
//        if (topIndexPath.section == indexPath.section) {
//            [tableView scrollToRowAtIndexPath:[NSIndexPath inde] atScrollPosition:<#(UITableViewScrollPosition)#> animated:<#(BOOL)#>]
//        }
    }
    
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
        
        TvConnection* connection = [[TvConnection alloc] initWithTmdbId:((TmdbTV*)posterView.movie).id completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
            
            if (code == WebserviceResultOk) {
                self.selectedSection = indexPath.section;
                
                [self.view addSubview:self.animatedPosterView];
                
                [self.animatedPosterView animateGrowWithCompletion:^{
                    
                    self.view.userInteractionEnabled = YES;
                    
                    Teebee* teebee = [Teebee teebeeWithTmdbTV:tv];
                    
                    [self goToTvDetailsScreenForTeebee:teebee andTv:tv];
                }];
            }
        }];
        
        connection.activityIndicator = posterView.activityIndicator;
        [self.connectionsManager startConnection:connection];
    }

}

- (void)goToTvDetailsScreenForTeebee:(Teebee*)teebee andTv:(TmdbTV*)tv {
    
    TvViewController* viewController = [[TvViewController alloc] initWithNibName:@"TvViewController" bundle:nil];
    viewController.teebee = teebee;
    viewController.tmdbTv = tv;
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

@end
