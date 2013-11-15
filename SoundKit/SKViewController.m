//
//  SKViewController.m
//  SoundKit
//
//  Created by david karam on 11/4/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKViewController.h"
#import "SKField.h"

@implementation SKViewController

SKField * scene;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
    
    // Create and initialize a tap gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(showGestureForPinchRecognizer:)];
    
    // Add the tap gesture recognizer to the view
    [self.view addGestureRecognizer:pinch];
    
    // Create and configure the scene.
    scene = [SKField sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (IBAction)showGestureForPinchRecognizer:(UIPinchGestureRecognizer *)recognizer {
    // tell the scene about the pinch scale
    [scene setTimeScale:[recognizer scale]];
}


@end
