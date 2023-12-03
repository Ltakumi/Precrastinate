import SwiftUI
import CoreData

struct TasksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentMission: Mission?
    @State private var isWorking = false
    @State private var currentSessionStart: Date?
    @State private var currentSessionDuration = TimeInterval(0)
    @State private var todayTotalDuration = TimeInterval(0)
    @State private var timer: Timer?
    @State private var todayIntervals: [Interval] = []
    @State private var missions: [Mission] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("Tasks - \(formatDate(Date()))")
                    .font(.title2)

                Section(header: Text("Current session")) {
                    Text(formatDuration(currentSessionDuration))
                        .font(.title)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }

                Section(header: Text("Today total")) {
                    Text(formatDuration(todayTotalDuration))
                        .font(.title)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Section(header : Text("Today intervals")) {
                    List {
                        ForEach(todayIntervals, id: \.self) { interval in
                            Text(interval.formatInterval())
                        }
                    }
                }
                
                Picker("Select Mission", selection: $currentMission) {
                    ForEach(missions, id: \.self) { mission in
                        Text(mission.name ?? "Unknown")
                        .font(.title2) // Increase font size
                        .tag(mission as Mission?)
                    }
                    
                }

                if isWorking {
                    Button(action: endTask) {
                        Text("End Task")
                            .endTaskButtonStyle()
                    }
                    
                } else {
                    Button(action: startTask) {
                        Text("Start Task")
                            .startTaskButtonStyle()
                    }
                }
            }
            .padding()
            .navigationBarItems(trailing: NavigationLink(destination: MissionsView()) {
                Text("Mission Settings")
            })
            .onAppear {
                fetchMissions()
                CalculateTodayTotal()
            }
        }
    }

    private func fetchMissions() {
        let request: NSFetchRequest<Mission> = Mission.fetchRequest()
        do {
            missions = try viewContext.fetch(request)
        } catch {
            print("Error fetching missions: \(error)")
        }
    }
    
    private func fetchIntervals() -> [Interval] {
        let request: NSFetchRequest<Interval> = Interval.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isProcrastination == %@", NSNumber(value: false)),
            NSPredicate(format: "start >= %@", startOfDay as NSDate),
            NSPredicate(format: "start < %@", endOfDay as NSDate)
        ])
        
        let sortDescriptor = NSSortDescriptor(key: "start", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching intervals: \(error)")
            return []
        }
    }

    private func CalculateTodayTotal() {
        todayIntervals = fetchIntervals()
        todayTotalDuration = todayIntervals.reduce(0) { total, interval in
            let duration = interval.end?.timeIntervalSince(interval.start ?? Date()) ?? 0
            return total + duration
        }
    }

    private func startTask() {
        guard currentMission != nil else { return }
        currentSessionStart = Date()
        isWorking = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let start = currentSessionStart {
                let additionalTime = Date().timeIntervalSince(start) - self.currentSessionDuration
                self.currentSessionDuration += additionalTime
                self.todayTotalDuration += additionalTime
            }
        }
    }

    private func endTask() {
        isWorking = false
        timer?.invalidate()
        timer = nil

        if let start = currentSessionStart, let mission = currentMission {
            let interval = Interval(context: viewContext)
            interval.start = start
            interval.end = Date()
            interval.isProcrastination = false
            interval.mission = mission

            CalculateTodayTotal()
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving session: \(error)")
            }
        }
        currentSessionDuration = 0
        currentSessionStart = nil
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }

}

extension Text {
    func startTaskButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(40)
            .shadow(radius: 5)
            .padding(.horizontal)
    }

    func endTaskButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return TasksView().environment(\.managedObjectContext, context)
    }
}
