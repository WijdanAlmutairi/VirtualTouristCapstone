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
    
    static func getURLFromParameter(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.ApiScheme
        components.host = Constants.Flickr.ApiHost
        components.path = Constants.Flickr.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem (name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print(components.url!)
        return components.url!
    }
}
