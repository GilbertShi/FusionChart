//
//  FusionChartsXTiOSExerciseViewController.h
//  FusionChartXTIOSExercise
//
//  Created by Gilbert on 4/28/13.
//  Copyright (c) 2013 Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FusionChartsXTiOSExerciseViewController : UIViewController

// webView to hold the chart
@property (nonatomic,retain) IBOutlet UIWebView *webView;

// chart properties.
@property (nonatomic,retain) NSMutableString *htmlContent;
@property (nonatomic, retain) NSMutableString *javascriptPath;
@property (nonatomic, retain) NSMutableString *chartData;
@property (nonatomic, retain) NSMutableString *chartType;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, assign) CGFloat chartWidth;
@property (nonatomic, assign) CGFloat chartHeight;
@property (nonatomic, retain) NSMutableString *debugMode;
@property (nonatomic, retain) NSMutableString *registerWithJavaScript;

// twitter data
@property (nonatomic, retain) NSMutableString *twitterQuery;
@property (nonatomic, retain) NSMutableData *twitterData;
@property (nonatomic, retain) NSDictionary *twitterDataDictionary;
@property (nonatomic, assign) BOOL twitterDataError;

// method
- (void)displayDataError;
- (void)createChartData:(UIInterfaceOrientation)interfaceOrientation;
- (void)plotChart;
- (void)removeChart;

@end
