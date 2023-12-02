import Foundation
import CoreData

// Data structure to export Missions
struct MissionExport: Codable {
    var name: String?
    var details: String?
    var startDate: Date?
    var endDate: Date?
    var completed: Bool

    init(from mission: Mission) {
        self.name = mission.name
        self.details = mission.details
        self.startDate = mission.start_date
        self.endDate = mission.end_date
        self.completed = mission.completed
    }
}

// Data structure to export Intervals
struct IntervalExport: Codable {
    var start: Date?
    var end: Date?
    var isProcrastination: Bool
    var comments: String?
    var mission: String?

    init(from interval: Interval) {
        self.start = interval.start
        self.end = interval.end
        self.isProcrastination = interval.isProcrastination
        self.comments = interval.comments
        if let mission = interval.mission {
            self.mission = mission.name
        }
    }
}

//This approach helps to resolve the type inference issue by wrapping each exportable entity in AnyCodable, which is itself Codable.
// This should allow you to combine different types of Codable objects into a single dictionary and then encode that dictionary to JSON.
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ encodable: T) {
        encodeFunc = encodable.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

// Function to encode to jsonData
func encodeToJson<T: Encodable>(combinedData: T) -> Data? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted // Enable pretty-printed JSON output

    do {
        let jsonData = try encoder.encode(combinedData)
        return jsonData
    } catch {
        print("Error encoding to JSON: \(error)")
        return nil
    }
}

// Fetch the data
func fetchAllMissionsAndIntervals(context: NSManagedObjectContext) -> ([Mission], [Interval]) {
    let missionRequest: NSFetchRequest<Mission> = Mission.fetchRequest()
    let intervalRequest: NSFetchRequest<Interval> = Interval.fetchRequest()

    do {
        let missions = try context.fetch(missionRequest)
        let intervals = try context.fetch(intervalRequest)
        return (missions, intervals)
    } catch {
        print("Error fetching data: \(error)")
        return ([], [])
    }
}

// Create combined data
func createCombinedData(missions: [Mission], intervals: [Interval]) -> Data {
    // Convert missions and intervals to their exportable formats
    let missionExports = missions.map { AnyEncodable(MissionExport(from: $0)) }
    let intervalExports = intervals.map { AnyEncodable(IntervalExport(from: $0)) }

    // Combine them with other entities into a single dictionary
    var combinedData: [String: [AnyEncodable]] = [
        "missions" : missionExports,
        "intervals" : intervalExports
    ]
    
    // Encode the combined data to JSON
    return encodeToJson(combinedData: combinedData) ?? Data()
}

// Top-level function
func exportMissionsAndIntervalsAsJson(context: NSManagedObjectContext) -> Data {
    // Fetch all missions and intervals
    let (missions, intervals) = fetchAllMissionsAndIntervals(context: context)

    // Create combined data in JSON format
    return createCombinedData(missions: missions, intervals: intervals)
}
