//
//  ViewController.m
//  LineTest
//
//  Created by administrator on 12-9-9.
//  Copyright (c) 2012年 administrator. All rights reserved.
//

#import "LineViewController.h"
#import "RootViewController.h"
@interface LineViewController ()

@end

@implementation LineViewController
@synthesize mapView;
@synthesize distanceLable;
@synthesize speedLable;
@synthesize timeLable;
@synthesize points;
@synthesize routeLine;
@synthesize routeLineView;

@synthesize locationManger;
@synthesize currentLocation;

//- (void)back
//{
//    [self presentModalViewController:[[RootViewController alloc] init] animated:YES];
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
   
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    // configure location manager
    [self configureRoutes];
    
    pathLength = 0;
    mTime = 0;
}

- (void)configureRoutes
{
    //define min,max points
    MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f);
    MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f);
    
    //create a c array of ponits
    MKMapPoint *pointarray = malloc(sizeof(CLLocationCoordinate2D) *points.count);
    for (int idx = 0; idx < points.count; idx++)
    {
        CLLocation *location = [points objectAtIndex:idx];
        CLLocationDegrees latitude = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        
        //create our coordinate and add it to the correct spot in the array
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
        //if it is the first point ,just use them,since we have nothing compare to yet
        if (idx == 0)
        {
            northEastPoint = point;
            southWestPoint = point;
        }else{
            if (point.x > northEastPoint.x) {
                northEastPoint.x = point.x;
            }
            if (point.y > northEastPoint.y) {
                northEastPoint.y = point.y;
            }
            if (point.x < southWestPoint.x) {
                southWestPoint.x = point.x;
            }
            if (point.y < southWestPoint.y) {
                southWestPoint.y = point.y;
            }
            
        }
        pointarray[idx] = point;
    }
    if (self.routeLine)
    {
        [self.mapView removeOverlay:self.routeLine];
    }
    self.routeLine = [MKPolyline polylineWithPoints:pointarray count:points.count];
    
    //add the overlay to the map
    if (self.routeLine != nil) {
        [self.mapView addOverlay:self.routeLine];
    }
    //clear the memory allocated earlier for the points
    free(pointarray);
}
#pragma mark
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    NSLog(@"%@----%@",self,NSStringFromSelector(_cmd));
    MKOverlayView *overlayView = nil;
    if (overlay == self.routeLine) {
        //if we have not yet created an overlay view for this overlay,creat it now;
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
        overlayView = self.routeLineView;
    }
    return overlayView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    //check the zero point
    if (userLocation.coordinate.latitude == 0.0f || userLocation.coordinate.longitude == 0.0f) {
        return;
    }
    //check the move distance
    if (points.count > 0) {
        CLLocationDistance distance = [location distanceFromLocation:currentLocation];
        if (distance < 5) {
            return;
        }else
            pathLength +=distance;
    }
    if (points == nil) {
        points = [[NSMutableArray alloc] init];
    }
    [points addObject:location];
    currentLocation = location;
    NSLog(@"points:%@",points);
    
    [self configureRoutes];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setDistanceLable:nil];
    [self setSpeedLable:nil];
    [self setTimeLable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
  //set Timer
- (void)starTimer
{
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAdvanced:) userInfo:nil repeats:YES];
}

- (void)timerAdvanced:(NSTimer *)timer
{
    if (judge == -1)
    {
        [timer invalidate];
        
    }
    //[self starTimer];
    mTime++;
    timeLable.text = [NSString stringWithFormat:@"%02d:%02d",mTime/60,mTime%60];
    distanceLable.text = [NSString stringWithFormat:@"%d",pathLength];
}

- (IBAction)go:(id)sender
{
    [self starTimer];
    if (judge == -1) {
        judge = 0;
        pathLength = 0;
    }
    if (mTime != 0) {
        mTime = 0;
    }
}
- (IBAction)end:(id)sender
{
    judge = -1;
    speedLable.text = [NSString stringWithFormat:@"%d",pathLength/mTime];
    
}

-(void)openView
{
    UIViewController *targetViewController = [[LineViewController alloc] init];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
