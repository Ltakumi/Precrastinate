import SwiftUI

struct IntervalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var interval: Interval
    @State private var start: Date
    @State private var end: Date
    @State private var isProcrastination: Bool
    @State private var comments: String
    @State private var selectedMission: Mission?
    @State private var showDeleteConfirmation = false
    @FetchRequest(entity: Mission.entity(), sortDescriptors: [])
    private var missions: FetchedResults<Mission>

    init(interval: Interval) {
        self._interval = ObservedObject(wrappedValue: interval)
        self._start = State(initialValue: interval.start ?? Date())
        self._end = State(initialValue: interval.end ?? Date())
        self._isProcrastination = State(initialValue: interval.isProcrastination)
        self._comments = State(initialValue: interval.comments ?? "")
        self._selectedMission = State(initialValue: interval.mission)
    }

    var body: some View {
        Form {
            DatePicker("Start", selection: $start)
            DatePicker("End", selection: $end)
            Toggle("Procrastination", isOn: $isProcrastination)
            TextField("Comments", text: $comments)

            if !isProcrastination {
                Picker("Mission", selection: $selectedMission) {
                    ForEach(missions, id: \.self) { mission in
                        Text(mission.name ?? "Unknown").tag(mission as Mission?)
                    }
                }
            }

            Button("Save") {
                interval.start = start
                interval.end = end
                interval.isProcrastination = isProcrastination
                interval.comments = comments
                interval.mission = isProcrastination ? nil : selectedMission

                do {
                    try viewContext.save()
                } catch {
                    print("Error saving interval: \(error)")
                }
            }
            
            Button("Delete", role: .destructive) {
                showDeleteConfirmation = true
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this interval?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteInterval()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle("Edit Interval")
    }
    
    private func deleteInterval() {
        viewContext.delete(interval)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting interval: \(error)")
        }
    }
    
}
