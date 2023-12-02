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
    
    func formatInterval() -> String {
        guard let start = start, let end = end else { return "N/A" }
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss"
        let startTimeString = dateformatter.string(from: start)

        let duration = end.timeIntervalSince(start)
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.hour, .minute, .second]
        durationFormatter.unitsStyle = .positional
        durationFormatter.zeroFormattingBehavior = .pad
        
        let durationString = durationFormatter.string(from: duration) ?? "N/A"

        var title = isProcrastination ? "Procrastinate" : (mission?.name ?? "Unknown Mission")

        return "\(title): \(startTimeString) - \(durationString)"
    }
}

extension Interval : Identifiable {

}
