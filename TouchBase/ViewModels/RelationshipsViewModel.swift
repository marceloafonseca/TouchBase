import Foundation

// Add this enum at the top level, outside the class
enum GroupOption: Identifiable, Hashable {
    case preset(Relationship.Group)
    case custom(CustomGroup)
    
    var id: String {
        switch self {
        case .preset(let group): return "preset-\(group.rawValue)"
        case .custom(let group): return "custom-\(group.id.uuidString)"
        }
    }
    
    var name: String {
        switch self {
        case .preset(let group): return group.rawValue
        case .custom(let group): return group.name
        }
    }
}

class RelationshipsViewModel: ObservableObject {
    @Published var relationships: [Relationship] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(relationships) {
                UserDefaults.standard.set(encoded, forKey: "relationships")
            }
        }
    }
    
    @Published var touchPoints: [TouchPoint] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(touchPoints) {
                UserDefaults.standard.set(encoded, forKey: "touchPoints")
            }
        }
    }
    
    @Published var customGroups: [CustomGroup] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(customGroups) {
                UserDefaults.standard.set(encoded, forKey: "customGroups")
            }
        }
    }
    
    @Published var tasks: [Task] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(tasks) {
                UserDefaults.standard.set(encoded, forKey: "tasks")
            }
        }
    }
    
    init() {
        // Load relationships
        if let savedRelationships = UserDefaults.standard.data(forKey: "relationships"),
           let decodedRelationships = try? JSONDecoder().decode([Relationship].self, from: savedRelationships) {
            self.relationships = decodedRelationships
        }
        
        // Load touch points
        if let savedTouchPoints = UserDefaults.standard.data(forKey: "touchPoints"),
           let decodedTouchPoints = try? JSONDecoder().decode([TouchPoint].self, from: savedTouchPoints) {
            self.touchPoints = decodedTouchPoints
        }
        
        // Load custom groups
        if let savedCustomGroups = UserDefaults.standard.data(forKey: "customGroups"),
           let decodedCustomGroups = try? JSONDecoder().decode([CustomGroup].self, from: savedCustomGroups) {
            self.customGroups = decodedCustomGroups
        }
        
        // Load tasks
        if let savedTasks = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            self.tasks = decodedTasks
        }
    }
    
    func addRelationship(_ relationship: Relationship) {
        relationships.append(relationship)
    }
    
    func updateRelationship(
        _ relationship: Relationship,
        newName: String,
        newGroup: Relationship.GroupType,
        newLastMet: Date,
        newIntensity: Relationship.MeetingFrequency
    ) {
        if let index = relationships.firstIndex(where: { $0.id == relationship.id }) {
            relationships[index].name = newName
            relationships[index].group = newGroup
            relationships[index].lastMet = newLastMet
            relationships[index].intensity = newIntensity
        }
    }
    
    func deleteRelationship(_ relationship: Relationship) {
        relationships.removeAll { $0.id == relationship.id }
        touchPoints.removeAll { $0.relationshipId == relationship.id }
    }
    
    func addTouchPoint(relationshipId: UUID, date: Date, notes: String = "") {
        let touchPoint = TouchPoint(relationshipId: relationshipId, date: date, notes: notes)
        touchPoints.append(touchPoint)
        
        // Update last met date for the relationship
        if let index = relationships.firstIndex(where: { $0.id == relationshipId }) {
            relationships[index].lastMet = date
        }
    }
    
    // This will be expanded later with actual rules
    var weeklyTasks: [Relationship] {
        relationships.filter { relationship in
            guard let lastContactDays = Calendar.current.dateComponents([.day], from: relationship.lastMet, to: Date()).day else {
                return false
            }
            
            switch relationship.intensity {
            case .weekly: return lastContactDays >= 7
            case .biweekly: return lastContactDays >= 14
            case .monthly: return lastContactDays >= 30
            case .bimonthly: return lastContactDays >= 60
            }
        }
    }
    
    func addCustomGroup(_ group: CustomGroup) {
        customGroups.append(group)
    }
    
    func updateCustomGroup(_ group: CustomGroup, newName: String, newDescription: String) {
        if let index = customGroups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            updatedGroup.name = newName
            updatedGroup.description = newDescription
            customGroups[index] = updatedGroup
        }
    }
    
    func deleteCustomGroup(_ group: CustomGroup) {
        customGroups.removeAll { $0.id == group.id }
    }
    
    var sortedRelationships: [Relationship] {
        relationships.sorted { $0.lastMet > $1.lastMet }
    }
    
    func moveRelationshipsFromPresetGroup(_ groupName: String) {
        // Move relationships to first available group or create a new one
        let targetGroup: Relationship.GroupType
        if let firstCustomGroup = customGroups.first {
            targetGroup = .custom(firstCustomGroup.name)
        } else if let firstPresetGroup = Relationship.Group.allCases.first {
            targetGroup = .preset(firstPresetGroup)
        } else {
            return
        }
        
        for (index, relationship) in relationships.enumerated() {
            if case .preset(let group) = relationship.group, group.rawValue == groupName {
                relationships[index].group = targetGroup
            }
        }
    }
    
    func getTouchPoints(for relationship: Relationship) -> [TouchPoint] {
        touchPoints
            .filter { $0.relationshipId == relationship.id }
            .sorted { $0.date > $1.date }
    }
    
    func updatePresetGroup(_ group: Relationship.Group, newName: String) {
        // Update all relationships using this preset group
        for (index, relationship) in relationships.enumerated() {
            if case .preset(let existingGroup) = relationship.group, existingGroup == group {
                relationships[index].group = .preset(group) // This will trigger the didSet and save
            }
        }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
} 