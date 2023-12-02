import SwiftUI
import CoreData

struct DayView: View {
    var date: Date
    @Environment(\.managedObjectContext) private var viewContext

    private var intervalsForDay: FetchRequest<Interval>

    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        self.intervalsForDay = FetchRequest<Interval>(
            entity: Interval.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Interval.start, ascending: true)],
            predicate: NSPredicate(format: "start >= %@ AND start < %@", argumentArray: [startOfDay, endOfDay])
        )
    }

    var body: some View {
        List {
            ForEach(intervalsForDay.wrappedValue, id: \.self) { interval in
                NavigationLink(destination: IntervalView(interval: interval)) {
                    Text(interval.formatInterval())
                }
            }
        }
        .navigationTitle("Day: \(date.formatted(date: .long, time: .omitted))")
    }
}

//#Preview {
//    DayView()
//}
