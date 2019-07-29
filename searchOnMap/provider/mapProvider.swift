//
//  mapProvider.swift
//  searchOnMap
//
//  Created by Luciano de Castro Martins on 27/06/2018.
//  Copyright © 2018 luciano. All rights reserved.
//

import Foundation


class mapProvider {
    
    /// calls the mapp api for the given text address
    ///
    /// - Parameters:
    ///   - text: the text to search
    ///   - completion: closure that will be called after api returns the result for the given query text
    func findLocation(text: String, _ completion: @escaping ([Location])->()) {
        var locations = [Location]()
        let kGoogleApiKey = "AIzaSyBZWmxLIDFXGTPkR9fTLiNTaU3rq4Wq8Jo"
        let handledText = text.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(handledText)&key=\(kGoogleApiKey)")
            else { return }
        URLSession(configuration: .default).dataTask(with: url) { (data, response, err) in
            if (err != nil) {
                print("an error ocurred when calling the api: ", err ?? "")
                return
            }
            guard let dd = data else { return }
            do {
                let result = try JSONSerialization.jsonObject (with: dd, options: .allowFragments) as! [String: Any]
                let locals = result["results"] as! [AnyHashable]
                locals.forEach({ d in
                    let dict = d as! [String: Any]
                    let loc = Location(dict)
                    locations.append(loc)
                })
                completion(locations)
            } catch {
                print("an error ocurred when parsing the api")
            }
        }.resume()
    }
}
