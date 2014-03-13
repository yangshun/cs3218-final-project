//
//  ViewController.m
//  Noisy Ninjas
//
//  Created by YangShun on 13/3/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface ViewController () {
    NSTimer *gameTimer;
    UIImageView *ninja;
    BOOL updatePosition;
    BOOL directionIsUp;
    NSMutableArray *shurikens;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    CGRect screenBounds = [[UIScreen mainScreen] bounds];
//    self.view.frame = CGRectMake(0, 0, screenBounds.size.height,
//                                 screenBounds.size.width);
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                 target:self
                                               selector:@selector(tick)
                                               userInfo:nil
                                                repeats:YES];
    
    directionIsUp = YES;
    
    ninja = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ninja-blue"]];
    ninja.frame = CGRectMake(0, 0, NINJA_HEIGHT, NINJA_WIDTH);
    [self.view addSubview:ninja];
    
    shurikens = [NSMutableArray new];
}

- (void)tick {
    if (updatePosition) {
        [self updateNinjaPosition];
    }
    
    [self updateShurikensPosition];
}

- (void)updateNinjaPosition {
    int movement = directionIsUp ? -MOVEMENT_DIST : MOVEMENT_DIST;
    float newY = ninja.center.y + movement;
    newY = MIN(newY, SCREEN_HEIGHT - NINJA_HEIGHT/2);
    newY = MAX(NINJA_HEIGHT/2, newY);
    ninja.center = CGPointMake(ninja.center.x, newY);
}

- (void)updateShurikensPosition {
    
    NSMutableArray *outOfBoundsShurikens = [NSMutableArray new];
    
    for (UIImageView *shuriken in shurikens) {
        shuriken.center = CGPointMake(shuriken.center.x + 20.f,
                                      shuriken.center.y);
        shuriken.transform = CGAffineTransformRotate(shuriken.transform, 10.f);
        
        if (shuriken.center.x > SCREEN_WIDTH) {
            [outOfBoundsShurikens addObject:shuriken];
            [shuriken removeFromSuperview];
        }
    }
    
    [shurikens removeObjectsInArray:outOfBoundsShurikens];
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
    UIImageView *shuriken = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shuriken-4-point-star"]];
    shuriken.frame = CGRectMake(0, 0, SHURIKEN_SIZE, SHURIKEN_SIZE);
    shuriken.center = CGPointMake(ninja.center.x + 40.f, ninja.center.y);
    [shurikens addObject:shuriken];
    [self.view addSubview:shuriken];
}

@end
