//
//  AppDelegate.h
//  FusionChartXTIOSExercise
//
//  Created by Gilbert on 4/28/13.
//  Copyright (c) 2013 Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FusionChartsXTiOSExerciseViewController;
@class ViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    UIWindow *window;
    FusionChartsXTiOSExerciseViewController *viewController;
};
@property (strong, nonatomic)  UIWindow *window;
@property (strong,nonatomic)   FusionChartsXTiOSExerciseViewController *viewController;
@property (strong,nonatomic) ViewController *vc;
@end
