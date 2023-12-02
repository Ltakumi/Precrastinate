import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<3 {
            let newItem = Interval(context: viewContext)
            
            newItem.isProcrastination = true
            
            newItem.start = Date()
            let durationInSeconds = Int.random(in: 600...1800) // Random duration between 10 and 30 minutes
            newItem.end = Calendar.current.date(byAdding: .second, value: durationInSeconds, to: newItem.start!)
            
        }
        
        for i in 0..<3 {
            let newItem = Interval(context: viewContext)
            
            newItem.isProcrastination = false
            
            newItem.start = Date()
            let durationInSeconds = Int.random(in: 600...1800) // Random duration between 10 and 30 minutes
            newItem.end = Calendar.current.date(byAdding: .second, value: durationInSeconds, to: newItem.start!)
            
        }
        
        for i in 0..<3 {
            let newItem = Mission(context: viewContext)
            newItem.name = "Task \(i)"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Precrastinate")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
