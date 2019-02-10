//
//  EventInformation.swift
//  VirtualTourist
//
//  Created by MAC on 09/02/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import Foundation

struct EventInformation{
    
    var eventName: String
    var eventImageUrl: String
    var eventWebPageUrl: String
    
    mutating func initWithValues(_ currentEvent : EventInformation) {
        self.eventName = currentEvent.eventName
        self.eventImageUrl = currentEvent.eventImageUrl
        self.eventWebPageUrl = currentEvent.eventWebPageUrl
    }
}
