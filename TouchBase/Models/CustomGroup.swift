import Foundation

struct CustomGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String
}
