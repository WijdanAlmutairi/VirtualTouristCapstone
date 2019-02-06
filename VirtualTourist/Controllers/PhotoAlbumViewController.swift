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
    var blockOperations = BlockOperation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       // handleFetchRequest()
        
        //if fetchedResultsController.fetchedObjects?.count == 0  {
        DispatchQueue.main.async {
            self.showPhotos()
        }
        
        
       // }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPin()
        print("will")
    }
    
    func handleFetchRequest () {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        print("\(pin.latitude), \(pin.longitude)")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        print("\(sortDescriptor)")
        print("\(predicate)")
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataPersistence.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
             print("\(fetchedResultsController.fetchedObjects?.count)")
           // collectionView.reloadData()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func newPhotoPressed(_ sender: Any) {
        showPhotos()
        handleFetchRequest()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        let imageUrl = URL(string: photo.imageUrl!)
        let resource = ImageResource(downloadURL: imageUrl!)
        cell.flickrPhoto.kf.setImage(with: resource)
        
        return cell
    }
    
    func showPhotos() {
        
        if let lat = coordinate?.latitude, let lon = coordinate?.longitude {
            self.networkObject.getPhoto(lat: lat, lon: lon) { (success, message, error, photoArray) in
                if (success == true){
                    for photo in photoArray{
                        
                        let imageString = photo["url_m"] as? String
                        if let imageString = imageString {
                            let photoToSave = Photo(context: DataPersistence.context)
                            
                            photoToSave.imageUrl = imageString
                            print("\(photoToSave.imageUrl)")
                            photoToSave.dateCreated = Date()
                            photoToSave.pin = self.pin
                            
                            DataPersistence.saveContext()
                        }
                    }
                    DispatchQueue.main.async {
                        self.handleFetchRequest()
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                        
                   }
                }else{
                    print(message)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            blockOperations.start()
        }, completion: nil)
       // collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            blockOperations.addExecutionBlock {
                 self.collectionView.insertItems(at: [newIndexPath!])
            }
        
        case .delete:
            print("delete")
        case .move:
            print("move")
        case .update:
            blockOperations.addExecutionBlock {
                self.collectionView.reloadItems(at: [indexPath!])
            }
        default:
            break
        }
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
