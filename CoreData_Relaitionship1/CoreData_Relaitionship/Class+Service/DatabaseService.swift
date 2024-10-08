import Foundation
import SwiftData

class DatabaseService {
    static var shared = DatabaseService()
    var container: ModelContainer?
    var context: ModelContext?

    init() {
        do {
            container = try ModelContainer(for: TodoModel.self)
            if let container {
                context = ModelContext(container)
            }
        } catch {
            print("Error initializing database container:", error)
        }
    }
    
    func saveTask(taskName: String?) {
        guard let taskName = taskName else { return }
        if let context = context {
            let taskToBeSaved = TodoModel(
                id: UUID().uuidString,
                taskname: taskName,
                time: Date().timeIntervalSince1970
            )
            context.insert(taskToBeSaved)
        }
    }
    
    func fetchTasks(onCompletion: @escaping ([TodoModel]?, Error?) -> Void) {
         let descriptor = FetchDescriptor<TodoModel>()
        if let context = context {
            do {
                let data = try context.fetch(descriptor)
                onCompletion(data, nil)
            } catch {
                onCompletion(nil, error)
            }
        }
    }
    
    func deleteTasks(ids: Set<String>) {
        guard let context = context else { return }
        let descriptor = FetchDescriptor<TodoModel>()
        do {
            let tasksToDelete = try context.fetch(descriptor).filter { ids.contains($0.id) }
            for task in tasksToDelete {
                context.delete(task)
            }
            try context.save()
        } catch {
            print("Error fetching tasks for deletion:", error)
        }
    }

}
