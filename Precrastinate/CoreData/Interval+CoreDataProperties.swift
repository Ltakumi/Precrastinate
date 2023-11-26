//
//  Interval+CoreDataProperties.swift
//  Precrastinate
//
//  Created by Louis Takumi on 2023/11/26.
//
//

import Foundation
import CoreData


extension Interval {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Interval> {
        return NSFetchRequest<Interval>(entityName: "Interval")
    }

    @NSManaged public var start: Date?
    @NSManaged public var end: Date?
    @NSManaged public var isProcrastination: Bool
    @NSManaged public var comments: String?
    @NSManaged public var mission: Mission?

}

extension Interval : Identifiable {

}
