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
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var coordinate: CLLocationCoordinate2D?
    var networkObject = NetworkConnection()
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.delegate = self
        collectionView.dataSource = self
        handleFetchRequest()
        if fetchedResultsController.fetchedObjects?.count == 0 {
            showPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPin()
    }
    
    func handleFetchRequest () {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataPersistence.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
           
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func newPhotoPressed(_ sender: Any) {
        deleteAll()
        showPhotos()
    }
    
    @IBAction func findEventPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showEvent", sender: self)
    }
    func deleteAll(){
        if let photoArray = fetchedResultsController.fetchedObjects {
         for photo in photoArray {
            DataPersistence.context.delete(photo)
            try? DataPersistence.context.save()
        }
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        let imageUrl = URL(string: photo.imageUrl!)
        let resource = ImageResource(downloadURL: imageUrl!)
        cell.flickrPhoto.kf.indicatorType = .activity
        cell.flickrPhoto.kf.setImage(with: resource, placeholder: UIImage(named: "Placeholder"))
        if let image = cell.flickrPhoto.image {
            let imageData = image.pngData()
            photo.imageData = imageData
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        DataPersistence.context.delete(photoToDelete)
        try? DataPersistence.context.save()
    }
    
    func showPhotos() {
        
        if let lat = coordinate?.latitude, let lon = coordinate?.longitude {
            self.networkObject.getPhoto(lat: lat, lon: lon) { (success, message, error, photoArray) in
                if (success == true && photoArray.isEmpty == false){
                    for photo in photoArray{
                        
                        let imageString = photo["url_m"] as? String
                        if let imageString = imageString {
                            let photoToSave = Photo(context: DataPersistence.context)
                            
                            photoToSave.imageUrl = imageString
                            photoToSave.dateCreated = Date()
                            photoToSave.pin = self.pin
                            
                            DataPersistence.saveContext()
                        }
                    }
                    DispatchQueue.main.async {
                        self.handleFetchRequest()
                   }
                }else {
                    if (photoArray.isEmpty == true) {
                        self.showAlert(message: "Photos for this location is unavailable")
                    
                }
            }
         }
      }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.collectionView.reloadData()
        case .delete:
            self.collectionView.reloadData()
        case .move:
            self.collectionView.reloadData()
       case .update:
            self.collectionView.reloadData()
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let eventVc = segue.destination as! EventViewController
        eventVc.lat = pin.latitude
        eventVc.lon = pin.longitude
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
