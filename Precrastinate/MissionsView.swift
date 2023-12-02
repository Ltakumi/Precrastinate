import SwiftUI

struct MissionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Mission.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Mission.name, ascending: true)]
    ) private var missions: FetchedResults<Mission>
    @State private var showingAddMissionView = false

    var body: some View {
        List(missions, id: \.self) { mission in
            NavigationLink(destination: MissionView(mission: mission)) {
                Text(mission.name ?? "Unnamed Mission")
            }
        }
        .navigationTitle("Missions")
        .navigationBarItems(trailing: Button(action: {
            showingAddMissionView = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddMissionView) {
            AddMissionView().environment(\.managedObjectContext, self.viewContext)
        }
    }
}

struct MissionsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return MissionsView().environment(\.managedObjectContext, context)
    }
}
