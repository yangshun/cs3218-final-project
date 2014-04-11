//
//  CategorySelectionViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "CategorySelectionViewController.h"
#import "SpellViewController.h"
#import "Utils.h"
#import "Constants.h"

@interface CategorySelectionViewController () {
    OpenEarsVoiceManager *openEarsVoiceManager;
}

@end

@implementation CategorySelectionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using
    SpellViewController *vc = [segue destinationViewController];
    
    NSArray *items = @[@"APPLE", @"BANANA", @"CHERRY", @"STRAWBERRY", @"BLUEBERRY", @"PEAR", @"ORANGE", @"LEMON", @"LIME", @"PEACH", @"WATERMELON", @"COCONUT", @"PINEAPPLE"];
    NSArray *fiveRandomItems = [[[Utils sharedManager] shuffle:items] subarrayWithRange:NSMakeRange(0, NUMBER_OF_WORDS_IN_LEVEL)];
    vc.wordsArray = fiveRandomItems;
    
    openEarsVoiceManager = [OpenEarsVoiceManager sharedOpenEarsVoiceManager];
    [openEarsVoiceManager changeWordList:items];
}


@end
