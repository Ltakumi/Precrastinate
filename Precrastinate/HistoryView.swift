import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Interval.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Interval.start, ascending: false)]
    ) private var intervals: FetchedResults<Interval>

    private var dayStatistics: [(date: Date, procrastination: TimeInterval, onTask: TimeInterval)] {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: intervals, by: { interval -> Date in
            calendar.startOfDay(for: interval.start ?? Date())
        })

        return groupedByDay.map { (date, intervals) in
            let totalProcrastination = intervals.filter { $0.isProcrastination }.reduce(0) { (result, interval) in
                result + (interval.end?.timeIntervalSince(interval.start ?? Date()) ?? 0)
            }
            let totalOnTask = intervals.filter { !$0.isProcrastination }.reduce(0) { (result, interval) in
                result + (interval.end?.timeIntervalSince(interval.start ?? Date()) ?? 0)
            }
            return (date, totalProcrastination, totalOnTask)
        }.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        NavigationView {
            List(dayStatistics, id: \.date) { dayStat in
                NavigationLink(destination: DayView(date: dayStat.date)) {
                    VStack(alignment: .leading) {
                        Text(dayStat.date.formatted(date: .abbreviated, time: .omitted))
                        Text("Procrastination: \(formatDuration(dayStat.procrastination))")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Text("On Task: \(formatDuration(dayStat.onTask))")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "00:00:00"
    }
}

#Preview {
    HistoryView()
}
