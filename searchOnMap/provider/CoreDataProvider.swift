//
//  CoreDataProvider.swift
//  searchOnMap
//
//  Created by Luciano de Castro Martins on 28/06/2018.
//  Copyright © 2018 luciano. All rights reserved.
//

import Foundation
import UIKit
import CoreData

typealias IsSavedResult = (isSaved: Bool?, object: CoreDataLocation?)

class CoreDataProvider {
    
    struct CoreDataProviderKeys {
        static let alternativeFormattedAddress =  "alternativeFormattedAddress"
        static let formattedAddress = "formattedAddress"
        static let coordinates = "coordinates"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let coreDataLocationIdentifier = "CoreDataLocation"
    }
    
    
    /// tells if a given location is already saved
    ///
    /// - Parameter location: the location to search
    /// - Returns: an instance of IsSavedResult
    func isSaved(_ location: Location) -> IsSavedResult {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return (isSaved: false, object: nil)
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataProviderKeys.coreDataLocationIdentifier)
        var savedResult: IsSavedResult = (isSaved: false, object: nil)
        
        do {
            let objects = try context.fetch(fetchRequest)
            var alreadySaved = false
            for item in objects {
                if let coreDataObject = item as? CoreDataLocation {
                    alreadySaved = coreDataObject.latitude == location.latitude
                        && coreDataObject.longitude == location.longitude
                        && coreDataObject.formattedAddress == location.formattedAddress
                        && coreDataObject.alternativeFormattedAddress == location.alternativeFormattedAddress
                    savedResult = (isSaved: alreadySaved, object: coreDataObject)
                }
                if alreadySaved {
                    break
                }
            }
        } catch let error as NSError {
            print("Could not fetch object. \(error), \(error.userInfo)")
        }
        return savedResult
    }
    
    
    /// save a location to the core data context
    ///
    /// - Parameter location: the location to save
    func saveData(_ location: Location) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            let saved = isSaved(location)
            if let isSaved =  saved.isSaved,
                isSaved {
                return
            }
            guard let entity = NSEntityDescription.entity(forEntityName: CoreDataProviderKeys.coreDataLocationIdentifier, in: context) else { return }
            
            let storeObject = NSManagedObject(entity: entity, insertInto: context)
            storeObject.setValue(location.alternativeFormattedAddress, forKey: CoreDataProviderKeys.alternativeFormattedAddress)
            storeObject.setValue(location.formattedAddress, forKey: CoreDataProviderKeys.formattedAddress)
            storeObject.setValue(location.coordinates, forKey: CoreDataProviderKeys.coordinates)
            storeObject.setValue(location.latitude, forKey: CoreDataProviderKeys.latitude)
            storeObject.setValue(location.longitude, forKey: CoreDataProviderKeys.longitude)
            try context.save()
            
        } catch let error as NSError {
            print("Could not save object. \(error), \(error.userInfo)")
        }
    }
    
    
    /// delete a location from the context
    ///
    /// - Parameter location: the location for deletion
    func deleteData(_ location: Location) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        do {
            let saved = isSaved(location)
            if let isSaved =  saved.isSaved,
                !isSaved {
                return
            }
            guard let objectToDelete = saved.object else { return }
            context.delete(objectToDelete)
            try context.save()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}
