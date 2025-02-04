import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var relationshipIds: [UUID]
    var createdAt: Date
    var isCompleted: Bool
    
    var formattedDate: String {
        createdAt.formatted(date: .abbreviated, time: .omitted)
    }
} 