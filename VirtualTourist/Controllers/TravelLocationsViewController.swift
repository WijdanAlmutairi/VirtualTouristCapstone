//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by MAC on 22/01/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var lat = 0.0
    var lon = 0.0
    var selectedAnnotation: MKPointAnnotation?
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(addPin))
        longPress.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
   @objc func addPin(gestureRecognizer:UIGestureRecognizer) {
    
    let touchPoint = gestureRecognizer.location(in: mapView)
    let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    let annotation = MKPointAnnotation()
    annotation.title = "pin dropped"
    annotation.coordinate = newCoordinates
    mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoVc = segue.destination as! PhotoAlbumViewController
        photoVc.coordinate = location
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? MKPointAnnotation
        location = selectedAnnotation?.coordinate
        //let photoVc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
       // photoVc.coordinate = location
       
      DispatchQueue.main.async {
           //self.show(photoVc, sender: self)
           self.performSegue(withIdentifier: "showPhoto", sender: self)
      }
        
    }
    
}


