//
//  ViewController.m
//  Noisy Ninjas
//
//  Created by YangShun on 13/3/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@interface ViewController () {
    NSTimer *gameTimer;
    UIImageView *ninja;
    BOOL updatePosition;
    BOOL directionIsUp;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.067f
                                        target:self
                                      selector:@selector(updateNinjaPosition:)
                                      userInfo:nil
                                       repeats:YES];
    [gameTimer fire];
    
    directionIsUp = YES;
    
    ninja = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ninja-blue"]];
    ninja.frame = CGRectMake(0, 0, 100.f, 89.f);
    [self.view addSubview:ninja];
    
}
                 
- (void)updateNinjaPosition:(id)sender {
    if (updatePosition) {
        int movement = directionIsUp ? -MOVEMENT_DIST : MOVEMENT_DIST;
        ninja.center = CGPointMake(ninja.center.x,
                                   ninja.center.y + movement);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)upButtonTouchDown {
    updatePosition = YES;
    directionIsUp = YES;
}

- (IBAction)downButtonTouchDown {
    updatePosition = YES;
    directionIsUp = NO;
}

- (IBAction)cancelMovement {
    updatePosition = NO;
}

- (IBAction)shoot:(id)sender {
    NSLog(@"shoot");
}

@end
