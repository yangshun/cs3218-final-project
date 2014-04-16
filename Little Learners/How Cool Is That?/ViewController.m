//
//  ViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "GameAudioManager.h"

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

@end
