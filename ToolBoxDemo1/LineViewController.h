//
//  ViewController.h
//  LineTest
//
//  Created by administrator on 12-9-9.
//  Copyright (c) 2012年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LineViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>
{
    //the map view
    MKMapView *mapView;
    
    //routes points
    NSMutableArray *points;
    
    //the data representing the route points
    MKPolyline *routeLine;
    
    //the view we create for the line on the map
    MKPolylineView *routeLineView;
    
    //the rect that bounds the loaded points
    MKMapRect routeRect;
    
    //location manager;
    CLLocationManager *locationManger;
    
    //current location
    CLLocation *currentLocation;
    
    //path length
    int pathLength;
    
    //counter
    int mTime;
    //judge
    int judge;
}
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UILabel *distanceLable;
@property (retain, nonatomic) IBOutlet UILabel *speedLable;
@property (retain, nonatomic) IBOutlet UILabel *timeLable;

@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView *routeLineView;

@property (nonatomic, retain) CLLocationManager *locationManger;
@property (nonatomic,retain) CLLocation *currentLocation;
- (IBAction)go:(id)sender;
- (IBAction)end:(id)sender;
- (void)openView;

@end
