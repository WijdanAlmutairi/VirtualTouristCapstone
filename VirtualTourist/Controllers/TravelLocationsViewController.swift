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
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pinArray = [Pin]()
    
    var lat = 0.0
    var lon = 0.0
    var selectedAnnotation: MKPointAnnotation?
    var location: CLLocationCoordinate2D?
    var selectedPin = Pin(context: DataPersistence.context)
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(addPin))
        longPress.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(longPress)
    
        handleFetchRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func handleFetchRequest() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do{
            let pins = try DataPersistence.context.fetch(fetchRequest)
            self.pinArray = pins
            showPin (array: pinArray)
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
   @objc func addPin(gestureRecognizer:UIGestureRecognizer) {
    
    let touchPoint = gestureRecognizer.location(in: mapView)
    let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    let annotation = MKPointAnnotation()
    annotation.title = "pin dropped"
    annotation.coordinate = newCoordinates
    mapView.addAnnotation(annotation)
    
    //save pin information
    let pin = Pin(context: DataPersistence.context)
    pin.latitude = annotation.coordinate.latitude
    pin.longitude = annotation.coordinate.longitude
    DataPersistence.saveContext()
    handleFetchRequest()
    }
    
    func showPin (array: [Pin]){
        for pin in array {
            
          var coordinate = CLLocationCoordinate2D()
            coordinate.latitude =  pin.latitude
            coordinate.longitude = pin.longitude

          let annotation = MKPointAnnotation()
          annotation.title = "pin dropped"
          annotation.coordinate = coordinate
          mapView.addAnnotation(annotation)

        }
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
        photoVc.pin = selectedPin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? MKPointAnnotation
        location = selectedAnnotation?.coordinate
        
        DispatchQueue.main.async {
            for onePin in self.pinArray {
                if onePin.latitude == self.location?.latitude && onePin.longitude == self.location?.longitude{
                    self.selectedPin = onePin
                    print("in pin")
                }
            }
           self.performSegue(withIdentifier: "showPhoto", sender: self)
      }
        
    }
    
}


