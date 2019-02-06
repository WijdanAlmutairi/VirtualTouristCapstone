//
//  NetworkConnection.swift
//  VirtualTourist
//
//  Created by MAC on 26/01/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import CoreData

class NetworkConnection {
    
    func getPhoto (lat: Double, lon: Double ,_ completionHandler: @escaping (_ result: Bool, _ message: String, _ error: Error?, _ imageArray:[[String: AnyObject]])->()){
        
         //Photos.removePhotos()
        let pageNumber = randomNumber()
        
        let methodParameters = [Constants.FlickrParameterKeys.apiKey: Constants.FlickrParameterValues.apiKeyValue,
            Constants.FlickrParameterKeys.method: Constants.FlickrParameterValues.methodValue,
            Constants.FlickrParameterKeys.format: Constants.FlickrParameterValues.formatVlaue,
            Constants.FlickrParameterKeys.latitude: "\(lat)",
            Constants.FlickrParameterKeys.longitude: "\(lon)",
            Constants.FlickrParameterKeys.tag: Constants.FlickrParameterValues.tagValue,
            Constants.FlickrParameterKeys.perPage: Constants.FlickrParameterValues.photoPerPage,
            Constants.FlickrParameterKeys.page: "\(pageNumber)",
            Constants.FlickrParameterKeys.accuracy: Constants.FlickrParameterValues.accuracyValue,
            Constants.FlickrParameterKeys.imageUrl: Constants.FlickrParameterValues.imageUrlValue,
            Constants.FlickrParameterKeys.noJasonCallBack:        Constants.FlickrParameterValues.noJasonCallBackValue]
        
        let request = URLRequest(url: Constants.getURLFromParameter(methodParameters as [String: AnyObject]))
        
            let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
                
                guard (error == nil) else {
                    completionHandler (false, "", error, [[:]])
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    completionHandler (false, "Your request returned a status code other than 2xx!", error,  [[:]])
                    return
                }
                
                guard let data = data else {
                    completionHandler (false, "No data was returned by the request!", error,  [[:]])
                    
                    return
                }
                
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                    
                } catch {
                    completionHandler (false, "Could not parse the data as JSON: '\(data)'", error,  [[:]])
                    return
                }
                
                guard let photos = parsedResult[Constants.FlickrResponseKeys.photos] as? [String: AnyObject] else {
                    completionHandler (false, "Cannot find key '\(Constants.FlickrResponseKeys.photos)' in \(String(describing: parsedResult))", error,  [[:]])
                    return
                }
                
                guard let photo = photos[Constants.FlickrResponseKeys.photo] as? [[String: AnyObject]] else {
                    completionHandler (false, "Cannot find key '\(Constants.FlickrResponseKeys.photo)' in \(String(describing: photos))", error,  [[:]])
                    return
                }
                
                    //self.extractImageUrl(photoArray: photo)
                    completionHandler (true, "", nil,  photo)
            }
            task.resume()
    }
    
    func randomNumber() -> Int{
        return Int.random(in: 1..<40)
    }
    
    func extractImageUrl(photoArray: [[String: AnyObject]]) {
        
        for photo in photoArray{
    
            let imageString = photo["url_m"] as? String
            if let imageString = imageString {
              let photoToSave = Photo(context: DataPersistence.context)
                
              photoToSave.imageUrl = imageString
              print("\(photoToSave.imageUrl)")
              photoToSave.dateCreated = Date()
            //  photoToSave.pin
          
              //let currentPhotoUrl = URL(string: photoToSave.imageUrl!)
//                DispatchQueue.main.async {
//
//              let imageView = UIImageView()
//              imageView.kf.setImage(with: currentPhotoUrl)
//             
//              print("here")
//              let data = imageView.image!.jpegData(compressionQuality: 1)
//               photoToSave.imageData = data
//              
//            }

                DataPersistence.saveContext()
          }
        }
        
    }
    
}
