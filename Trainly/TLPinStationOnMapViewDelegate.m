#import "TLPinStationOnMapViewDelegate.h"
#import "TLTrainStation.h"

@interface TLPinStationOnMapViewDelegate()

/**
 * Drops the pin on the station I'm displaying
 * @param mapView The map view I'm setting up
 */
-(void) dropPinOnStationForMap:(MKMapView*)mapView;

@end

@implementation TLPinStationOnMapViewDelegate

#pragma mark - Setup

-(void) focusCentrepointForMapView:(MKMapView*) mapView;
{
  CLLocationCoordinate2D coord;
  coord.latitude  = [[_trainStationData valueForKeyPath:@"latitude"]  doubleValue];
  coord.longitude = [[_trainStationData valueForKeyPath:@"longitude"] doubleValue];
  
  [_pin setCoordinate:coord];
  
  // Work out station info
  [_pin setTitle:   [_trainStationData valueForKeyPath:@"name"]];
  [_pin setSubtitle:[_trainStationData valueForKeyPath:@"suburb"]];
  
  // Set the map region
  MKCoordinateSpan span;
  span.latitudeDelta = 0.01f;
  span.longitudeDelta = 0.01f;
  MKCoordinateRegion reg = MKCoordinateRegionMake(coord, span);
  [mapView setRegion:reg animated:YES];
  
  // Show the bubble (only if the pin has been added!)
  if ([mapView viewForAnnotation:_pin])
    [mapView selectAnnotation:_pin animated:YES];
}

-(void) dropPinOnStationForMap:(MKMapView*)mapView
{
  // Actually create and drop the pin
  _pin = [[MKPointAnnotation alloc] init];
  
  // Focus on the area over pin
  [self focusCentrepointForMapView:mapView];
  
  // Add the annotation to the map
  [mapView addAnnotation:_pin];
  
  // Focus centrepoint automatically displays the bubble; we don't
  // want that to automatically happen when we load (since it should
  // automatically do it AFTER the animation)
  [mapView deselectAnnotation:_pin animated:NO];
}

#pragma mark - MKMapViewDelegate Protocol Implementation

- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
  // If I haven't dropped the pin
  if (!_pin)
    // Drop the pin!
    [self dropPinOnStationForMap:mapView];
}

//- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//  // Dequeue existing pin
//  MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CoordinatePin"];
//  
//  // If couldn't dequeue? Make new pin
//  if (!pinView)
//  {
//    pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation
//                                             reuseIdentifier:@"CoordinatePin"];
//    
//    // Set basics for these pins
//    [pinView setPinColor:MKPinAnnotationColorRed];
//    [pinView setAnimatesDrop:YES];
//    [pinView setCanShowCallout:YES];
//  }
//  else
//    pinView.annotation = annotation;
//  return pinView;
//}

// Automatically show the pin bubble when drop has finished
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
  for (MKAnnotationView *pinView in annotationViews)
  {
    CGRect endFrame = pinView.frame;
    pinView.frame = CGRectOffset(endFrame, 0, -500);
    [UIView animateWithDuration:0.65
                     animations:^{ pinView.frame = endFrame; }
                     // Use the completion to invoke the show annotation
                     completion:^(BOOL finished) { [mapView selectAnnotation:pinView.annotation animated:YES]; }];
  }
}

@end
