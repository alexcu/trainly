#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TLViewUsesStationData.h"

/**
 * A generic controller to handle displaying a single pin to MapViews
 * @author  Alex Cummaudo
 * @date    2014-04-04
 */
@interface TLPinStationOnMapViewDelegate : TLViewUsesStationData
  <MKMapViewDelegate>
{
  /// The pin I'm going to plot
  MKPointAnnotation* _pin;
}
















/**
 * Refocuses centrepoint on the pin
 */
-(void) focusCentrepointForMapView:(MKMapView*) mapView;

@end
