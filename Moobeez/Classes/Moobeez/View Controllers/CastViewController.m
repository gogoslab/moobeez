//
//  CastViewController.m
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "CastViewController.h"
#import "Moobeez.h"

@interface CastViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet BubblePopupView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CastViewController

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CharacterTableCell" bundle:nil] forCellReuseIdentifier:@"CharacterTableCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startAnimation {

    CGPoint sourceCenter = [self.sourceButton.superview convertPoint:self.sourceButton.center toView:self.view];
    
    CGPoint bubbleSourceCenter = [self.contentView.sourceButton.superview convertPoint:self.contentView.sourceButton.center toView:self.view];
    
    self.contentView.sourceButton.x += sourceCenter.x - bubbleSourceCenter.x;
    self.contentView.sourceButton.y += sourceCenter.y - bubbleSourceCenter.y;

    self.tableView.hidden = YES;
    
    [self.contentView startAnimation];
    self.contentView.animationCompletionHandler = ^{
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    };
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.castArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CharacterTableCell* cell = (CharacterTableCell*) [tableView dequeueReusableCellWithIdentifier:@"CharacterTableCell"];
    
    cell.character = self.castArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.characterSelectionHandler(self.castArray[indexPath.row]);
}

#pragma mark - Back Button

- (IBAction)backButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}


@end
