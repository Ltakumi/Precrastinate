import SwiftUI

struct ExportView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var documentPickerPresented = false
    @State private var currentFilename: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Button("Export") {
                    let exportData = exportMissionsAndIntervalsAsJson(context: viewContext)
                    currentFilename = "procrastination.json"
                    exportJsonData(jsonData: exportData, filename: currentFilename)
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Export Data")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Export Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $documentPickerPresented) {
            DocumentPicker(document: .constant(Data()), filename: $currentFilename, onPick: handlePickedDocument)
        }
    }

    private func exportJsonData(jsonData: Data, filename: String) {
        
        // Create a file URL for `locations.json` in the temporary directory
        let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)

        do {
            // Write the JSON data to the file
            try jsonData.write(to: tempFileURL)
            // Present the document picker to the user with the new file
            documentPickerPresented = true
        } catch {
            self.alertMessage = "Failed to write JSON data to file: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }
    
    private func handlePickedDocument(url: URL) {
        // Perform any action after the document is picked, if necessary
        self.alertMessage = "Export successful."
        self.showingAlert = true
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var document: Data
    @Binding var filename: String
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        let picker = UIDocumentPickerViewController(forExporting: [tempFileURL], asCopy: true) // asCopy should be true if you want the user to export a copy
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Not needed for this implementation
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        var onPick: (URL) -> Void

        init(_ picker: DocumentPicker, onPick: @escaping (URL) -> Void) {
            self.parent = picker
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}
