//
//  NetworkConnection.swift
//  VirtualTourist
//
//  Created by MAC on 26/01/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import Foundation
import UIKit

class NetworkConnection {
    
    //static var EventsArray: [EventInformation] = []
    
    var northeastLatitude = 0.0
    var northeastLongitude = 0.0
    var southwestLatitude = 0.0
    var southwestLongitude = 0.0
    
    func getPhoto (lat: Double, lon: Double ,_ completionHandler: @escaping (_ result: Bool, _ message: String, _ error: Error?, _ imageArray:[[String: AnyObject]])->()){
        
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
        
        let request = URLRequest(url: Constants.getURLFromParameterFlickr(methodParameters as [String: AnyObject]))
        
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
                
                    completionHandler (true, "", nil,  photo)
            }
            task.resume()
    }
    
    func randomNumber() -> Int{
        return Int.random(in: 1..<40)
    }
    
     func getEvent (lat: Double, lon: Double ,_ completionHandler: @escaping (_ result: Bool, _ message: String, _ error: Error?)->()){
        
        calculateViewport (lat: lat, lon: lon)
        AllEventsArray.EventsArray = []

        let methodParameters = [Constants.EventParameterKeys.latitude: "\(lat)", Constants.EventParameterKeys.longitude: "\(lon)", Constants.EventParameterKeys.latitudeNortheast: "\(northeastLatitude)", Constants.EventParameterKeys.longitudeNortheast: "\(northeastLongitude)", Constants.EventParameterKeys.latitudeSouthwest: "\(southwestLatitude)", Constants.EventParameterKeys.longitudeSouthwest: "\(southwestLongitude)", Constants.EventParameterKeys.expand: "\(Constants.EventParameterValues.expandValueOne),\(Constants.EventParameterValues.expandValueTwo)"]
        
        var request = URLRequest(url: Constants.getURLFromParameterEvent(methodParameters as [String: AnyObject]))

        request.addValue("Bearer CBLK3S7ENTUYYY33POCL", forHTTPHeaderField: "Authorization")
        request.addValue("json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
            
            guard (error == nil) else {
                completionHandler (false, "", error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler (false, "Your request returned a status code other than 2xx!", error)
                return
            }
            
            guard let data = data else {
                completionHandler (false, "No data was returned by the request!", error)
                
                return
            }
            
            let parsedResult: [String:AnyObject]!
            let value: String!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                
            } catch {
                completionHandler (false, "Could not parse the data as JSON: '\(data)'", error)
                return
            }
            
            guard let event = parsedResult[Constants.EventResponseKeys.events] as? [[String: AnyObject]] else {
                completionHandler (false, "Cannot find key '\(Constants.EventResponseKeys.events)' in \(String(describing: parsedResult))", error)
                return
            }
            self.extractEvent(eventArray: event)
            //print("\(event)")
            completionHandler (true, "", nil)
        }
        task.resume()
    }
    
    func calculateViewport (lat: Double, lon: Double){
        
        northeastLatitude = lat + 1
        northeastLongitude = lon + 1
        southwestLatitude = lat - 1
        southwestLongitude = lon - 1
    }
    
    func extractEvent(eventArray: [[String: AnyObject]]){
        
        for event in eventArray {
            let name = event["name"] as? [String: AnyObject] ?? ["name": "empty" as AnyObject]
            
            let eventName = name["text"] as? String ?? "empty"
            
            let image = event["logo"] as? [String: AnyObject] ?? ["logo": "empty" as AnyObject]
            
            let eventImageUrl = image["url"] as? String ?? "empty"
            
            let webPageUrl = event["url"] as? String ?? "empty"
            print("url page: \(webPageUrl)")
            
            if eventName != "empty" && eventImageUrl != "empty" {
                let eventObject = EventInformation(eventName: eventName, eventImageUrl: eventImageUrl, eventWebPageUrl: webPageUrl)
                AllEventsArray.EventsArray.append(eventObject)
            }
        }
    }
}
