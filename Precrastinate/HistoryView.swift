import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Interval.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Interval.start, ascending: false)]
    ) private var intervals: FetchedResults<Interval>

    private var uniqueDays: [Date] {
        let calendar = Calendar.current
        let days = intervals.map { interval in
            calendar.startOfDay(for: interval.start ?? Date())
        }
        return Array(Set(days)).sorted(by: { $0 > $1 })
    }

    var body: some View {
        NavigationView {
            List(uniqueDays, id: \.self) { day in
                NavigationLink(destination: DayView(date: day)) {
                    Text(day.formatted(date: .abbreviated, time: .omitted))
                }
            }
            .navigationTitle("History")
        }
    }
}


#Preview {
    HistoryView()
}
