//
//  ZCLocationController.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLocationController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUICore.h"
#import "ZCUIImageTools.h"

@interface ZCLocationController ()<CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    BOOL haveGetUserLocation;//是否获取到用户位置
    CLGeocoder *geocoder;
    NSMutableArray *infoArray;//周围信息
    UIImageView *imgView;//中间位置标志视图
    BOOL spanBool;//是否是滑动
    BOOL pinchBool;//是否缩放
    CLLocationManager *_locationManager;
    
    CLPlacemark *checkPlacemark;
    
    // 我的位置
    MKUserLocation *myLocation;
}

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *showTableView;
@property (strong, nonatomic) UIButton *resetLocationBtn;


@end

@implementation ZCLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if(!self.navigationController.navigationBarHidden){
        [self setNavigationBarStyle];
    }
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self createTitleView];
    
    [self.titleLabel setText:ZCSTLocalString(@"获取位置")];
    [self.moreButton setTitle:ZCSTLocalString(@"发送") forState:0];
    [self.moreButton setImage:nil forState:0];
    [self.moreButton setImage:nil forState:UIControlStateHighlighted];
    self.moreButton.hidden = NO;
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, 400)];
    [self.view addSubview:self.mapView];
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    self.showTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight+400, ScreenWidth, ScreenHeight - 400 - NavBarHeight) style:UITableViewStylePlain];
    self.showTableView.delegate = self;
    self.showTableView.dataSource = self;
    [self.view addSubview:self.showTableView];
    self.showTableView.tableFooterView = [UIView new];
    spanBool = NO;
    pinchBool = NO;
    geocoder=[[CLGeocoder alloc]init];
    infoArray = [NSMutableArray array];
    haveGetUserLocation = NO;
    //请求定位服务
    _locationManager=[[CLLocationManager alloc]init];
    if(![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    
    //先查看MapView层次结构
    // NSLog(@"mapview recursiveDescription:\n%@",[self.mapView performSelector:@selector(recursiveDescription)]);
    
    //打印完后我们发现有个View带有手势数组其类型为_MKMapContentView获取Span和Pinch手势
    for (UIView *view in self.mapView.subviews) {
        NSString *viewName = NSStringFromClass([view class]);
        if ([viewName isEqualToString:@"_MKMapContentView"]) {
            UIView *contentView = view;//[self.mapView valueForKey:@"_contentView"];
            for (UIGestureRecognizer *gestureRecognizer in contentView.gestureRecognizers) {
                if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewSpanGesture:)];
                }
                if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewPinchGesture:)];
                }
            }
            
        }
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self resetTableHeadView];
    
    
    
//    CLLocationCoordinate2D coordinate = {30.26667, 120.20000};
//    [_mapView setCenterCoordinate:coordinate animated:YES];
    
    // 定位按钮
    _resetLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake( CGRectGetMaxX(_mapView.frame)- 58, CGRectGetMaxY(_mapView.frame)- 58, 48, 48)];
    [_resetLocationBtn setImage:[ZCUITools zcuiGetBundleImage:@"icon_location_samemy"] forState:UIControlStateNormal];
    [_resetLocationBtn addTarget:self action:@selector(resetLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetLocationBtn];
}

- (void)resetLocation:(id)sender {
    spanBool = YES;
    
    // 定位到我的位置
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
    
    [_resetLocationBtn setImage:[ZCUITools zcuiGetBundleImage:@"icon_location_samemy"] forState:UIControlStateNormal];
    
}



// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_BACK){
        [self goBack];
    }
    
    if(sender.tag == BUTTON_SEND){
        if(checkPlacemark == nil){
            return;
        }
        //发送坐标点
        UIGraphicsBeginImageContextWithOptions(_mapView.frame.size, NO, 2.0);
        [_mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData * imageData =UIImageJPEGRepresentation(image, 0.75f);
        NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
        zcLibCheckPathAndCreate(zcLibGetDocumentsFilePath(@"/sobot/"));
        NSString *fullPath=zcLibGetDocumentsFilePath(fname);
        [imageData writeToFile:fullPath atomically:YES];
        
        CLLocationCoordinate2D coordinate= checkPlacemark.location.coordinate;
        
        NSDictionary *dict = @{@"lng":[NSString stringWithFormat:@"%f",coordinate.longitude],@"lat":[NSString stringWithFormat:@"%f",coordinate.latitude],@"localName":zcLibConvertToString(checkPlacemark.name),@"localLabel":zcLibConvertToString(checkPlacemark.addressDictionary[@"Street"]),@"file":zcLibConvertToString(fullPath)};
        
        if(_checkLocationBlock){
            _checkLocationBlock(dict);
        }
        
        [self goBack];
    }
}

-(void)goBack{
    if(self.navigationController != nil ){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    
}


-(void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
//    NSLog(@"mapViewWillStartLocatingUser");
}


-(void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
//    NSLog(@"mapViewDidStopLocatingUser");
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    NSLog(@"userLocation:longitude:%f---latitude:%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude);
    if (!haveGetUserLocation) {
        if (self.mapView.userLocationVisible) {
            haveGetUserLocation = YES;
            if(myLocation == nil){
                myLocation = userLocation;
            }
            [self getAddressByLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
            [self addCenterLocationViewWithCenterPoint:self.mapView.center];
        }
        
    }
//    if(myLocation!=nil){
        double dis = [self countDiance:userLocation];
        if(dis > 10){
            [_resetLocationBtn setImage:[ZCUITools zcuiGetBundleImage:@"icon_location_my"] forState:UIControlStateNormal];
        }else{
            [_resetLocationBtn setImage:[ZCUITools zcuiGetBundleImage:@"icon_location_samemy"] forState:UIControlStateNormal];
        }
//        if(myLocation.location.coordinate.longitude != mapView.centerCoordinate.longitude || myLocation.location.coordinate.latitude != mapView.centerCoordinate.latitude ){
//        }
//    }
}


/**
 计算当前坐标离中心点的位置

 @return 返回距离米
 */
-(double)countDiance:(MKUserLocation *) myLocation{
    CLLocationCoordinate2D coor[2] = {0};
    coor[0].latitude = self.mapView.centerCoordinate.latitude;
    coor[0].longitude = self.mapView.centerCoordinate.longitude;
    coor[1].latitude = myLocation.location.coordinate.latitude;
    coor[1].longitude = myLocation.location.coordinate.longitude;
    CLLocation *send = [[CLLocation alloc]initWithLatitude:coor[0].latitude longitude:coor[0].longitude];
    CLLocation *receive = [[CLLocation alloc]initWithLatitude:coor[1].latitude longitude:coor[1].longitude];
    CLLocationDistance dis = [send distanceFromLocation:receive];
    NSString *disSendStr = [NSString stringWithFormat:@"%.03fkm",dis/1000.00];
//    NSLog(@"%@",disSendStr);
    return dis;
}


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
//    NSLog(@"didFailToLocateUserWithError:%@",error.localizedDescription);
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    NSLog(@"regionWillChangeAnimated");
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    NSLog(@"regionDidChangeAnimated");
    if (imgView && (spanBool||pinchBool)) {
        [infoArray removeAllObjects];
        [self.showTableView reloadData];
        [self resetTableHeadView];
        CGPoint mapCenter = self.mapView.center;
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:mapCenter toCoordinateFromView:self.mapView];
        [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
        imgView.center = CGPointMake(mapCenter.x, mapCenter.y-15);
        [UIView animateWithDuration:0.2 animations:^{
            imgView.center = mapCenter;
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    imgView.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            imgView.transform = CGAffineTransformIdentity;
                        }completion:^(BOOL finished){
                            if (finished) {
                                spanBool = NO;
                            }
                        }];
                    }
                }];
                
            }
        }];
    }
    
}


#pragma mark - Private Methods
-(void)resetTableHeadView
{
    if (infoArray.count>0) {
        self.showTableView.tableHeaderView = nil;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30.0)];
        view.backgroundColor = self.showTableView.backgroundColor;
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = view.center;
        [indicatorView startAnimating];
        [view addSubview:indicatorView];
        self.showTableView.tableHeaderView = view;
        
    }
}


-(void)addCenterLocationViewWithCenterPoint:(CGPoint)point
{
    if (!imgView) {
        imgView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 100, 21, 36)];
        imgView.center = point;
        imgView.image = [ZCUITools zcuiGetBundleImage:@"icon_location_pin"];
        imgView.center = self.mapView.center;
        [self.view addSubview:imgView];
    }
    
}

-(void)getAroundInfoMationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 50, 50);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.region = region;
    request.naturalLanguageQuery = @"Restaurants";
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            [self getAroundInfomation:response.mapItems];
        }else{
            haveGetUserLocation = NO;
//            NSLog(@"Quest around Error:%@",error.localizedDescription);
        }
    }];
}


-(void)getAroundInfomation:(NSArray *)array
{
    for (MKMapItem *item in array) {
        MKPlacemark * placemark = item.placemark;
//        ZHPlaceInfoModel *model = [[ZHPlaceInfoModel alloc]init];
//        model.name = placemark.name;
//        model.thoroughfare = placemark.thoroughfare;
//        model.subThoroughfare = placemark.subThoroughfare;
//        model.city = placemark.locality;
//        model.coordinate = placemark.location.coordinate;
//        [infoArray addObject:model];
        [infoArray addObject:placemark];
    }
    [self.showTableView reloadData];
}


#pragma mark 根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initialData:placemarks];
                [self getAroundInfoMationWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                [self.showTableView reloadData];
                [self resetTableHeadView];
            });
        }else{
            haveGetUserLocation = NO;
//            NSLog(@"error:%@",error.localizedDescription);
        }
        
    }];
}


#pragma mark - Initial Data
-(void)initialData:(NSArray *)places
{
    [infoArray removeAllObjects];
    for (CLPlacemark *placemark in places) {
//        ZHPlaceInfoModel *model = [[ZHPlaceInfoModel alloc]init];
//        model.name = placemark.name;
//        model.thoroughfare = placemark.thoroughfare;
//        model.subThoroughfare = placemark.subThoroughfare;
//        model.city = placemark.locality;
//        model.coordinate = placemark.location.coordinate;
//        [infoArray insertObject:model atIndex:0];
        
        if(infoArray.count == 0){
            checkPlacemark = placemark;
        }
        [infoArray insertObject:placemark atIndex:0];
    }
}

#pragma mark － TableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    ZHPlaceInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdntifier forIndexPath:indexPath];
//    ZHPlaceInfoModel *model = [infoArray objectAtIndex:indexPath.row];
//    cell.titleLabel.text = model.name;
//    cell.subTitleLabel.text = model.thoroughfare;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    CLPlacemark *placemark = [infoArray objectAtIndex:indexPath.row];
    cell.textLabel.text = placemark.name;
    cell.detailTextLabel.text = placemark.subLocality;
    cell.tintColor = [ZCUITools zcgetBgBannerColor];
    //        CLPlacemark *placemark = [[ZHPlaceInfoModel alloc]init];
    //        model.name = placemark.name;
    //        model.thoroughfare = placemark.thoroughfare;
    //        model.subThoroughfare = placemark.subThoroughfare;
    //        model.city = placemark.locality;
    //        model.coordinate = placemark.location.coordinate;
    //        [infoArray insertObject:model atIndex:0];
    if(checkPlacemark !=nil && [placemark isEqual:checkPlacemark]){
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    return cell;
}



#pragma mark - TableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *placemark = [infoArray objectAtIndex:indexPath.row];
    
    checkPlacemark = placemark;
    [self.showTableView reloadData];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - touchs
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"moved");
    spanBool = YES;
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}


#pragma mark - MapView Gesture
-(void)mapViewSpanGesture:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
//            NSLog(@"SpanGesture Began");
        }
            break;
        case UIGestureRecognizerStateChanged:{
//            NSLog(@"SpanGesture Changed");
            spanBool = YES;
        }
            
            break;
        case UIGestureRecognizerStateCancelled:{
//            NSLog(@"SpanGesture Cancelled");
        }
            
            break;
        case UIGestureRecognizerStateEnded:{
//            NSLog(@"SpanGesture Ended");
        }
            
            break;
            
        default:
            break;
    }
}

-(void)mapViewPinchGesture:(UIGestureRecognizer*)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
//            NSLog(@"PinchGesture Began");
        }
            break;
        case UIGestureRecognizerStateChanged:{
//            NSLog(@"PinchGesture Changed");
            pinchBool = YES;
        }
            
            break;
        case UIGestureRecognizerStateCancelled:{
//            NSLog(@"PinchGesture Cancelled");
        }
            
            break;
        case UIGestureRecognizerStateEnded:{
            pinchBool = NO;
//            NSLog(@"PinchGesture Ended");
        }
            
            break;
            
        default:
            break;
    }
    
}




//**************************项目中的导航栏一部分是自定义的View,一部分是系统自带的NavigationBar*********************************
- (void)setNavigationBarStyle{
    [self setNavigationBarLeft:@[@(BUTTON_BACK)] right:@[@(BUTTON_SEND)]];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
