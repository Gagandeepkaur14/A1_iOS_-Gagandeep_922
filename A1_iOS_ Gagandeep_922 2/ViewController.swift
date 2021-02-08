//
//  ViewController.swift
//  A1_iOS_ Gagandeep_922
//
//  Created by gagandeep kaur on 2021-01-25.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Create Location Manager here
      var locationManager = CLLocationManager()
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var directionBtn: UIButton!
    // create  the places array
    let places = Place.getPlaces()
    
    //destination variable
      var destination: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
        
        
        directionBtn.isHidden = true
        // we assign the delegate property of the location manager to be this class
        locationManager.delegate = self
        
        // we define the accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //request  for the permission to access the location
        locationManager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        //Add Double Tap
        addDoubleTap()
        addAnnotationsForPlaces()
        // Giving the delegates of MKMapViewDelegate to this class
        // addPolyline()
       // addPolygon()
    }
    
    
    @IBAction func drawRoute(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
        directionBtn.isEnabled = true
    let sourceLocation = CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
        let destinationLocation1 = CLLocationCoordinate2D(latitude: 43.4675, longitude: -79.6877)
        let destinationLocation2 = CLLocationCoordinate2D(latitude: 43.5183, longitude: -79.8774)
    
        let sourcePlacemeark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation1)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemeark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let  sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "A"
        if let location = sourcePlacemeark.location {
            sourceAnnotation.coordinate = location.coordinate
            
        }
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "B"
        if let location = destinationPlacemark.location{
            destinationAnnotation.coordinate = location.coordinate
        }
        self.map.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate{(response, Error) in
            guard let directionsResponse = response else {return}
            
            //create the route
            let route = directionsResponse.routes[0]
            
            //draw  a polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            //define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        }
        let sourcePlacemeark1 = MKPlacemark(coordinate: destinationLocation1)
        let destinationPlacemark1 = MKPlacemark(coordinate: destinationLocation2)
        
        let sourceMapItem1 = MKMapItem(placemark: sourcePlacemeark1)
        let destinationMapItem1 = MKMapItem(placemark: destinationPlacemark1)
        
        let  sourceAnnotation1 = MKPointAnnotation()
        sourceAnnotation1.title = "B"
        if let location = sourcePlacemeark1.location {
            sourceAnnotation1.coordinate = location.coordinate
            
        }
        
    }
    
        //MARK: - draw route from point b to c
        
       
        
        
    
    
    //MARK: -didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userlocation  = locations[0]
        
        let latitude = userlocation.coordinate.latitude
        let longitude = userlocation.coordinate.longitude
        
        // Uncomment the displaylocation method to see the user location
      //displaylocation(latitude: latitude, longitude: longitude, title: "You are here", subtitle: " ")
        
        
}
    
    //MARK: - add annotation for the places
    func addAnnotationsForPlaces() {
        map.addAnnotations(places)
        
        let overlays = places.map {MKCircle(center: $0.coordinate, radius: 2000)}
       map.addOverlays(overlays)
        
    }
    
    //MARK: - ployline method
    func addPolyline()  {
        let  coordinates = places.map{$0.coordinate}
        let polyline  = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
        
        
    }
    
    //MARK: - POLYGON METHOD
    func addPolygon()  {
        let coordinates = places.map{$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
        
        
    }
    
    //MARK: - Remove pin from map
    func removePin()  {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
    }
    
    //MARK: - display user location method
    func displaylocation(latitude:CLLocationDegrees,
                         longitude:CLLocationDegrees,
                         title:String,subtitle:String)  {
        map.showsUserLocation = true
       // map.isZoomEnabled = false
            //2nd step - define span
            let latDelta:CLLocationDegrees = 0.05
            let lngDelta:CLLocationDegrees = 0.05
        
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
            
        // 3rd step is to define the location
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        //5th step is to set the region for map
        map.setRegion(region, animated: true)
        
        //6th step is to define the annotation
       let annotation = MKPointAnnotation()
        annotation.title = title
       annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)

      
        
    }
    
    //MARK: - Double Tap func
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        
        removePin()
        //add annotation
        let touchpoint = sender.location(in: map)
        let coordinate = map.convert(touchpoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "My Destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
        directionBtn.isHidden = false
        
    }
    }

    
extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
          //add Custom Annotation
          let pinAnnotation = map.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
          pinAnnotation.image = UIImage(named: "ic_place_2x")
         pinAnnotation.canShowCallout = true
         pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
          return pinAnnotation
          
          //custom marker
          let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
          annotationView.markerTintColor = UIColor.blue
        //  return annotationView
          
          
      }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertcontroller = UIAlertController(title: "Your Place", message: "A Nice Place to visit", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertcontroller.addAction(cancelAction)
        present(alertcontroller, animated: true, completion: nil)
        
        
    }
 //MARK: - Rendrer for overlay func

func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        
       if overlay is MKPolyline {
        let rendrer = MKPolylineRenderer(overlay: overlay)
        rendrer.strokeColor = UIColor.blue
        rendrer.lineWidth = 3
        return rendrer
        
    } else if overlay is MKPolygon {
        let  rendrer = MKPolygonRenderer(overlay: overlay)
        rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
        rendrer.strokeColor = UIColor.green
        rendrer.lineWidth = 3
        return rendrer
        
    }
    return MKOverlayRenderer()
}
     
}



