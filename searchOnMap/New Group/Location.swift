//
//  Location.swift
//  searchOnMap
//
//  Created by Luciano de Castro Martins on 28/06/2018.
//  Copyright © 2018 luciano. All rights reserved.
//

import Foundation
import GoogleMaps

struct ParseKeys {
    static let geometry = "geometry"
    static let location = "location"
    static let latitude = "lat"
    static let longitude = "lng"
    static let addresComponent = "address_components"
    static let firsAdminAreaLevel = "administrative_area_level_1"
    static let secondAdminAreaLevel = "administrative_area_level_2"
    static let countryLevel = "country"
    static let shortName = "short_name"
    static let longName = "long_name"
}
struct Location {
    var formattedAddress: String?
    var alternativeFormattedAddress: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var coordinates: String?
    
    
    
    
    init(_ dictionary: [String: Any]) {
        guard let geometry = dictionary[ParseKeys.geometry] as? [String: Any],
            let location = geometry[ParseKeys.location] as? [String: Any],
            let lat = location[ParseKeys.latitude] as? CLLocationDegrees,
            let lng = location[ParseKeys.longitude] as?  CLLocationDegrees,
            let addressComponents = dictionary[ParseKeys.addresComponent] as? [[String: Any]] else { return }
        
        let administrativeLevels = addressComponents.filter({ (d) -> Bool in
            let filtered =  d.values.filter({ val -> Bool in
                
                guard let valString = val as? [Any] else { return false }
                guard let elem = valString[0] as? String else { return false }
                return elem == ParseKeys.firsAdminAreaLevel ||
                    elem == ParseKeys.secondAdminAreaLevel ||
                    elem == ParseKeys.countryLevel
            })
            return filtered.count > 0
        })
        
        var address = ""
        var alternativeAddress = ""
        var index = 0
        
        administrativeLevels.forEach({ (dict) in
            if index > 0 {
                if let shortName = dict[ParseKeys.shortName] as? String,
                    let longName = dict[ParseKeys.longName] as? String {
                    address = index == 2 ? address + shortName : address + shortName + ", "
                    alternativeAddress = index == 2 ? alternativeAddress + longName : alternativeAddress + longName + ", "
                }
            } else if let longName = dict[ParseKeys.longName] as? String {
                address = address + longName + ", "
                alternativeAddress = alternativeAddress + longName + " - "
            }
            index += 1
        })
        
        formattedAddress = index == 2 ? String(address.dropLast().dropLast()) : address
        alternativeFormattedAddress = index == 2 ? String(alternativeAddress.dropLast().dropLast()) : alternativeAddress
        latitude = lat
        longitude = lng
        coordinates =  "(\(lat) \(lng))"
    }
}
