import Foundation

struct TouchPoint: Identifiable, Codable {
    var id = UUID()
    let relationshipId: UUID
    let date: Date
    let notes: String
} 