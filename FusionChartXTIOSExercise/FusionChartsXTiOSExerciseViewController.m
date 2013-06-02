//
//  FusionChartsXTiOSExerciseViewController.m
//  FusionChartXTIOSExercise
//
//  Created by Gilbert on 4/28/13.
//  Copyright (c) 2013 Gilbert. All rights reserved.
//

#import "FusionChartsXTiOSExerciseViewController.h"
#import "JSONKit.h"
@interface FusionChartsXTiOSExerciseViewController ()

@end

@implementation FusionChartsXTiOSExerciseViewController

@synthesize webView;
@synthesize htmlContent;
@synthesize javascriptPath;
@synthesize chartData;
@synthesize chartType;
@synthesize currentOrientation;
@synthesize chartWidth;
@synthesize chartHeight;
@synthesize debugMode;
@synthesize registerWithJavaScript;

@synthesize twitterQuery;
@synthesize twitterData;
@synthesize twitterDataDictionary;
@synthesize twitterDataError;

- (void) dealloc {
    [webView release];
	[htmlContent release];
	[javascriptPath release];
	[chartData release];
	[chartType release];
	[debugMode release];
	[registerWithJavaScript release];
	[twitterQuery release];
	[twitterData release];
	[twitterDataDictionary release];
    [super dealloc];
}

/* using UIWebView(*webView) to load NSMutableString(*displayErrorHTML) */
- (void)displayDataError {
	NSMutableString *displayErrorHTML = [NSMutableString stringWithString:@"<html><head>"];
	[displayErrorHTML appendString:@"<title>Chart Error</title>"];
	[displayErrorHTML appendString:@"</head><body>"];
	[displayErrorHTML appendString:@"<p>Unable to plot chart.<br/>Error receiving data from Twitter.</p>"];
	[displayErrorHTML appendString:@"</body></html>"];
	
	[self.webView loadHTMLString:displayErrorHTML baseURL:nil];
}

/* Called after the view has been loaded. For view controllers created in code, this is after -loadView.
   For view controllers unarchived from a nib, this is after the view is set.*/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // setup the twitter query.
    self.twitterQuery = [NSMutableString stringWithFormat:@"%@",@"http://otter.topsy.com/searchhistogram.json?q=html5&slice=86400&period=7&apikey=ENDBYBBDNOSAB6NNAMLAAAAAAA7M2GJGWBIQAAAAAAAFQGYA"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.twitterQuery]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // check weather we have a valid connection.
    if (connection) {
        // create the NSMutableData to hold the received data.
        self.twitterData = [NSMutableData data];
    } else {
        // error in receiving data
        self.twitterDataError = YES;
    }
    
    // done using the connection
    [connection release];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
	// (Re)Initialize the Twitter data store.
    [self.twitterData setLength:0];
}

/*
connection:didReceiveData: is called with a single immutable NSData object to the delegate, representing the next portion of the data loaded from the connection.  This is the only guaranteed for the delegate to receive the data from the resource load.<p>
*/
- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
    // Store received data.
    [self.twitterData appendData:data];
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *)error {
	// Display an error on connection failure.
    [self displayDataError];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection{
    
	// Convert received JSON data to an Objective-C dictionary.
    self.twitterDataDictionary = [self.twitterData objectFromJSONData];
    
    // create chart as per current orientation.
    self.currentOrientation = self.interfaceOrientation;
    [self createChartData: self.currentOrientation];
}

- (void)createChartData:(UIInterfaceOrientation)interfaceOrientation{
    // check weather we have valid data
    if (self.twitterDataError){
        [self displayDataError];
    } else {
		// Set chart width and height depending on the screen's orientation.
		if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			self.chartWidth = 300;
			self.chartHeight = 440;
		} else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			self.chartWidth = 440;
			self.chartHeight = 280;
		}
        
        // setup chart xml
        NSDictionary *responseData = [self.twitterDataDictionary objectForKey:@"response"];
        NSArray *histogramData = [responseData objectForKey:@"histogram"];
        self.chartData = [NSMutableString string];
        [self.chartData appendFormat:@"<chart caption='Twitter mentions of HTML5' subCaption='In the last 7 days' showValues='0'>"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        for (int i=0; i<[histogramData count]; i++) {
            [self.chartData appendFormat:@"<set label='%@' value='%@' />", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(i+1)*86400]],[histogramData objectAtIndex:i]];
        }
        [self.chartData appendFormat:@"</chart>"];
        [dateFormatter release];

        // setup chart html
        self.htmlContent = [NSMutableString stringWithFormat:@"%@",@"<html><head>"];
		[self.htmlContent appendString:@"<script type='text/javascript' src='FusionCharts.js'></script>"];
		[self.htmlContent appendString:@"</head><body><div id='chart_container'>Chart will render here.</div>"];
		[self.htmlContent appendString:@"<script type='text/javascript'>"];
		[self.htmlContent appendFormat:@"var chart_object = new FusionCharts('Column3D.swf', 'twitter_data_chart', '%f', '%f', '0', '1');", self.chartWidth, self.chartHeight];
		[self.htmlContent appendFormat:@"chart_object.setXMLData(\"%@\");", self.chartData];
		[self.htmlContent appendString:@"chart_object.render('chart_container');"];
		[self.htmlContent appendString:@"</script></body></html>"];
        
        // draw actual chart
        [self plotChart];
    }
}

- (void)plotChart {
    NSURL *baseURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",[[NSBundle mainBundle]bundlePath]]];
    NSLog(@"baseURL-->%@",baseURL);
    [self.webView loadHTMLString:self.htmlContent baseURL:baseURL];
}


- (void)removeChart {
	NSString *emptyChartContainer = @"<script type='text/javascript'>document.getElementById('chart_container').innerHTML='';</script>";
	[self.webView stringByEvaluatingJavaScriptFromString:emptyChartContainer];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	// Check whether we have valid data.
	if (self.twitterDataError) {
		[self displayDataError];
	} else {
        
        NSLog(@"cutentOrientation before-->%d",currentOrientation);
		// Valid data.
		// Store new orientation.
		self.currentOrientation = toInterfaceOrientation;
		// Remove existing chart and recreating it
		// as per the new orientation.
		[self removeChart];
        [self createChartData:self.currentOrientation];
        NSLog(@"cutentOrientation after-->%d",currentOrientation);
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation // iOS 6 autorotation fix
{
    return UIInterfaceOrientationPortrait;
    //return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
