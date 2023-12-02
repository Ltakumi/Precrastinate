//
//  MissionView.swift
//  Precrastinate
//
//  Created by Louis Takumi on 2023/12/01.
//

import SwiftUI

import SwiftUI

struct MissionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var mission: Mission
    @State private var missionName: String
    @State private var missionDetails: String
    @State private var missionStartDate: Date
    @State private var missionEndDate: Date

    init(mission: Mission) {
        self._mission = ObservedObject(wrappedValue: mission)
        self._missionName = State(initialValue: mission.name ?? "")
        self._missionDetails = State(initialValue: mission.details ?? "")
        self._missionStartDate = State(initialValue: mission.start_date ?? Date())
        self._missionEndDate = State(initialValue: mission.end_date ?? Date())
    }

    var body: some View {
        Section (header:Text("Mission info")) {
            
            TextField("Mission Name", text: $missionName, onCommit: saveChanges)
                .font(.headline)
            
            TextField("Details", text: $missionDetails, onCommit: saveChanges)
            
            DatePicker("Start Date", selection: $missionStartDate, displayedComponents: .date)
                .onChange(of: missionStartDate) { _ in saveChanges() }
            
            Toggle("Completed", isOn: Binding(
                get: { mission.completed },
                set: { newValue in
                    mission.completed = newValue
                    saveChanges()
                }
            ))
            
            if mission.completed {
                DatePicker("End Date", selection: $missionEndDate, displayedComponents: .date)
                    .onChange(of: missionEndDate) { _ in saveChanges() }
            }
            
            
        }
        .padding()
        .navigationTitle(missionName)
    }

    private func saveChanges() {
        mission.name = missionName
        mission.details = missionDetails
        mission.start_date = missionStartDate
        mission.end_date = mission.completed ? missionEndDate : nil

        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately
            print("Error saving mission: \(error)")
        }
    }
}

struct MissionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let mission = Mission(context: context) // Create a sample mission for preview
        return MissionView(mission: mission).environment(\.managedObjectContext, context)
    }
}
