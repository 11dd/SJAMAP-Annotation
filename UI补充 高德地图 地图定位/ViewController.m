//
//  ViewController.m
//  UI补充 高德地图 地图定位
//
//  Created by 曾思健 on 16/1/18.
//  Copyright © 2016年 曾思健. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (nonatomic,strong) MAMapView* mapView;
@property (nonatomic,strong) AMapSearchAPI* manager;
@property (nonatomic,strong) AMapNearbySearchRequest* request;
@property (nonatomic,strong) MAUserLocation* location;
@property (nonatomic,strong) AMapPOIAroundSearchRequest* POIrequest;
//存储周边点位置的数组
@property (nonatomic,strong) NSArray* arrOfPoi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MAMapServices sharedServices].apiKey=@"d2781706f11cc174197a8bc71d921e75";
    [AMapSearchServices sharedServices].apiKey=@"d2781706f11cc174197a8bc71d921e75";

    
    [self.myView addSubview:self.mapView];
    self.mapView.frame=self.myView.bounds;
    
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.mapView.delegate=nil;
}
- (IBAction)search:(id)sender
{
    AMapGeoPoint* point=[AMapGeoPoint locationWithLatitude:self.location.location.coordinate.latitude longitude:self.location.location.coordinate.longitude];
    
    self.request.center=point;
    //搜索半径
    self.request.radius=500;
    self.request.limit=50;
    
    self.POIrequest.keywords=@"酒店";
    self.POIrequest.location=point;
    self.POIrequest.radius=3000;
    
    [self.manager AMapPOIAroundSearch:self.POIrequest];
    [self.manager AMapNearbySearch:self.request];
    
}
-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    NSLog(@"%@,搜索完毕,%lu",request,(unsigned long)response.pois.count);
    self.arrOfPoi=response.pois;
    for (AMapPOI* poi in response.pois)
    {
        MAPointAnnotation* point=[[MAPointAnnotation alloc]init];
        point.coordinate=CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        point.title=poi.name;
//        MAAnnotationView * annotation=[MAAnnotationView alloc]initWithAnnotation:point reuseIdentifier:<#(NSString *)#>]
        [self.mapView addAnnotation:point];
    }
    
}

-(void)onNearbySearchDone:(AMapNearbySearchRequest *)request response:(AMapNearbySearchResponse *)response
{
    NSLog(@"%@,搜索完毕,%lu",request,(unsigned long)response.infos.count);
    
}
#pragma mark- 代理方法
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    self.location=userLocation;
    
    MACoordinateSpan span=MACoordinateSpanMake(0.005, 0.005);

    MACoordinateRegion region2=MACoordinateRegionMake(userLocation.location.coordinate, span);
//    self.mapView.region=region2;
    mapView.region=region2;
//    MAMapRect rect=MAMapRectMake(0, 0, 1000, 1000);
//    [mapView setVisibleMapRect:rect animated:YES];
//    NSLog(@"%f---%f",userLocation.location.coordinate.latitude,userLocation.coordinate.longitude);
    
//    [mapView setShowsUserLocation:YES];
}
#pragma mark- 懒加载
-(MAMapView *)mapView
{
    if (_mapView==nil)
    {
        _mapView=[[MAMapView alloc]init];
        _mapView.delegate=self;
//        _mapView.userTrackingMode=MAUserTrackingModeFollow;
        [_mapView setShowsUserLocation:YES];
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
        
        
    }
    return _mapView;
}
-(AMapSearchAPI*)manager
{
    if (_manager==nil)
    {
        _manager=[[AMapSearchAPI alloc]init];
        _manager.delegate=self;
    }
    return _manager;
}
-(AMapNearbySearchRequest *)request
{
    if (_request==nil)
    {
        _request=[[AMapNearbySearchRequest alloc]init];
        
    }
    return _request;
}
-(MAUserLocation *)location
{
    if (_location==nil)
    {
        _location=[[MAUserLocation alloc]init];
    }
    return _location;
}
-(AMapPOIAroundSearchRequest *)POIrequest
{
    if (_POIrequest==nil)
    {
        _POIrequest=[[AMapPOIAroundSearchRequest alloc]init];
    }
    return _POIrequest;
}
@end
