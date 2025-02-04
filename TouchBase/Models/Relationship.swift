import Foundation

struct Relationship: Identifiable, Codable {
    var id = UUID()
    var name: String
    var group: GroupType
    var lastMet: Date
    var intensity: MeetingFrequency
    
    enum GroupType: Codable, Equatable {
        case preset(Group)
        case custom(String)
        
        var name: String {
            switch self {
            case .preset(let group): group.rawValue
            case .custom(let name): name
            }
        }
    }
    
    enum Group: String, CaseIterable, Codable {
        case family = "Family"
        case friend = "Friend"
        case work = "Work"
    }
    
    enum MeetingFrequency: String, CaseIterable, Codable {
        case weekly = "1x Week"
        case biweekly = "2x Month"
        case monthly = "1x Month"
        case bimonthly = "Every 2 Months"
    }
    
    var touchPoints: [TouchPoint] {
        // This will be populated from the ViewModel
        []
    }
}
