//
//  CoreDataLocation+CoreDataProperties.swift
//  
//
//  Created by Luciano de Castro Martins on 28/06/2018.
//
//

import Foundation
import CoreData


extension CoreDataLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataLocation> {
        return NSFetchRequest<CoreDataLocation>(entityName: "CoreDataLocation")
    }

    @NSManaged public var formattedAddress: String?
    @NSManaged public var alternativeFormattedAddress: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var coordinates: String?

}
