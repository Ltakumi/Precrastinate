//
//  Mission+CoreDataProperties.swift
//  Precrastinate
//
//  Created by Louis Takumi on 2023/11/26.
//
//

import Foundation
import CoreData


extension Mission {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mission> {
        return NSFetchRequest<Mission>(entityName: "Mission")
    }

    @NSManaged public var name: String?
    @NSManaged public var details: String?
    @NSManaged public var start_date: Date?
    @NSManaged public var end_date: Date?
    @NSManaged public var completed: Bool
    @NSManaged public var intervals: NSSet?

}

// MARK: Generated accessors for intervals
extension Mission {

    @objc(addIntervalsObject:)
    @NSManaged public func addToIntervals(_ value: Interval)

    @objc(removeIntervalsObject:)
    @NSManaged public func removeFromIntervals(_ value: Interval)

    @objc(addIntervals:)
    @NSManaged public func addToIntervals(_ values: NSSet)

    @objc(removeIntervals:)
    @NSManaged public func removeFromIntervals(_ values: NSSet)

}

extension Mission : Identifiable {

}
