//
//  Search+CoreDataProperties.swift
//  WeatherApp
//
//  Created by admin on 6/23/22.
//
//

import Foundation
import CoreData


extension Search {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Search> {
        return NSFetchRequest<Search>(entityName: "Search")
    }

    @NSManaged public var searchString: String
    @NSManaged public var createdAt: Date
    @NSManaged public var cityId: String

}

extension Search : Identifiable {

}
