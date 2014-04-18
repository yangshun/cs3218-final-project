//
//  ViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "GameAudioManager.h"
#import "GameViewController.h"
#import "Constants.h"

@interface ViewController () {
    AVAudioPlayer *playSound;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[GameAudioManager sharedInstance] playBackgroundMusic];
}

- (IBAction)play:(id)sender {
    [[GameAudioManager sharedInstance] playPlaySound];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[GameAudioManager sharedInstance] stopBackgroundMusic];
    UIButton *btn = sender;
    if (btn.tag == 100) {
        GameViewController *gvc = [segue destinationViewController];
        gvc.categoryArray = [NSArray arrayWithObjects:FRUITS, ANIMALS, nil];
    }
}


@end
