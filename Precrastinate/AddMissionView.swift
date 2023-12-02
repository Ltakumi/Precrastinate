import SwiftUI
import CoreData

struct AddMissionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var startDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Mission Details")) {
                TextField("Name", text: $name)
                TextField("Details", text: $details)
            }

            Section(header: Text("Dates")) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            }

            Section {
                Button(action: saveMission) {
                    Text("Save Mission")
                }
            }
        }
        .navigationTitle("Add Mission")
        .navigationBarItems(trailing: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }

    private func saveMission() {
        let newMission = Mission(context: viewContext)
        newMission.name = name
        newMission.details = details
        newMission.start_date = startDate

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // Handle the error appropriately
            print("Error saving mission: \(error)")
        }
    }
}

struct AddMissionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return AddMissionView().environment(\.managedObjectContext, context)
    }
}
