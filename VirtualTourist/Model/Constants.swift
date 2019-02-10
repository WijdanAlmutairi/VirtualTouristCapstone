//
//  Constants.swift
//  VirtualTourist
//
//  Created by MAC on 26/01/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import Foundation


struct Constants {
    
    
    struct Flickr {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    }

    struct FlickrParameterKeys {
        static let apiKey = "api_key"
        static let method = "method"
        static let format = "format"
        static let latitude = "lat"
        static let longitude = "lon"
        static let tag = "tags"
        static let perPage = "per_page"
        static let page = "page"
        static let accuracy = "accuracy"
        static let imageUrl = "extras"
        static let noJasonCallBack = "nojsoncallback"
    }
    
    
    struct FlickrParameterValues {
        static let apiKeyValue = "4a05a6b8b0af2e091e1c8f42711b9405"
        static let methodValue = "flickr.photos.search"
        static let formatVlaue = "json"
        static let tagValue = "\"\""
        static let photoPerPage = "10"
        static let accuracyValue = "11"
        static let imageUrlValue = "url_m"
        static let noJasonCallBackValue = "1"
        
    }
    
    struct FlickrResponseKeys {
       static let photos = "photos"
       static let photo = "photo"
       static let photoURL = "url_m"
        
    }
    
    struct Event {
        static let ApiScheme = "https"
        static let ApiHost = "www.eventbriteapi.com"
        static let ApiPath = "/v3/events/search/"
    }
    
    struct EventParameterKeys {
        static let token = "token"
        static let latitude = "location.latitude"
        static let longitude = "location.longitude"
        static let latitudeNortheast = "location.viewport.northeast.latitude"
        static let longitudeNortheast = "location.viewport.northeast.longitude"
        static let latitudeSouthwest = "location.viewport.southwest.latitude"
        static let longitudeSouthwest = "location.viewport.southwest.longitude"
        static let expand = "expand"
    }
    
    struct EventParameterValues {
        static let tokenValue = "CBLK3S7ENTUYYY33POCL"
        static let expandValueOne = "venue"
        static let expandValueTwo = "orgnizer"
    }
    
    struct EventResponseKeys {
        static let events = "events"
    }
   
    static func getURLFromParameterFlickr(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.ApiScheme
        components.host = Constants.Flickr.ApiHost
        components.path = Constants.Flickr.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem (name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    static func getURLFromParameterEvent(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Event.ApiScheme
        components.host = Constants.Event.ApiHost
        components.path = Constants.Event.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem (name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}
