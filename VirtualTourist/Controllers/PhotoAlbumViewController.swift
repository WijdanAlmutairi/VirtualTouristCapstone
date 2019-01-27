//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by MAC on 23/01/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var coordinate: CLLocationCoordinate2D?
    var networkObject = NetworkConnection()

    override func viewDidLoad() {
        super.viewDidLoad()
         navigationController?.navigationBar.isHidden = true 
        //navigationItem.backBarButtonItem?.title = "Ok"
        
        if let lat = coordinate?.latitude, let lon = coordinate?.longitude {
            self.networkObject.getPhoto(lat: lat, lon: lon) { (success, message, error) in
                if (success == true){
                    DispatchQueue.main.async {
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                    }
                }else{
                    print(message)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPin()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Photos.flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let currentPhotoUrl = URL(string: Photos.flickrPhotos[indexPath.row])!
        let resource = ImageResource(downloadURL: currentPhotoUrl, cacheKey: Photos.flickrPhotos[indexPath.row])
        cell.flickrPhoto.kf.setImage(with: resource)
        return cell
    }
    
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func showPin() {
        if let coordinate = coordinate {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
}
