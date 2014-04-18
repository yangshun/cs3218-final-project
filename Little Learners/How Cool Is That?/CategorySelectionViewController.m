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
#import "GameAudioManager.h"

@interface CategorySelectionViewController () {
    OpenEarsVoiceManager *openEarsVoiceManager;
    AVAudioPlayer *exitSound;
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
    [[GameAudioManager sharedInstance] playBackgroundMusic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss {
    [[GameAudioManager sharedInstance] playExitSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    [[GameAudioManager sharedInstance] stopBackgroundMusic];
    [[GameAudioManager sharedInstance] playCategorySound];
    
    SpellViewController *vc = [segue destinationViewController];

    UIButton *btn = sender;
    NSArray *items;
    switch (btn.tag) {
            
        case 0:
            items = FRUITS;
            vc.type = Fruits;
            break;
        case 1:
            items = ANIMALS;
            vc.type = Animals;
            break;
        default:
            break;
    }

    NSArray *fiveRandomItems = [[[Utils sharedManager] shuffle:items] subarrayWithRange:NSMakeRange(0, NUMBER_OF_WORDS_IN_LEVEL)];
    vc.wordsArray = fiveRandomItems;

//    openEarsVoiceManager = [OpenEarsVoiceManager sharedOpenEarsVoiceManager];
//    openEarsVoiceManager.wordList = items;
}


@end
