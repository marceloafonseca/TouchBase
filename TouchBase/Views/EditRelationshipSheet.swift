import SwiftUI

struct EditRelationshipSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    let relationship: Relationship
    
    @State private var name: String
    @State private var selectedGroupOption: AddRelationshipSheet.GroupOption
    @State private var lastMet: Date
    @State private var intensity: Relationship.MeetingFrequency
    
    init(viewModel: RelationshipsViewModel, relationship: Relationship) {
        self.viewModel = viewModel
        self.relationship = relationship
        
        // Initialize state with current values
        _name = State(initialValue: relationship.name)
        _lastMet = State(initialValue: relationship.lastMet)
        _intensity = State(initialValue: relationship.intensity)
        
        // Set initial group selection
        switch relationship.group {
        case .preset(let group):
            _selectedGroupOption = State(initialValue: .preset(group))
        case .custom(let name):
            if let customGroup = viewModel.customGroups.first(where: { $0.name == name }) {
                _selectedGroupOption = State(initialValue: .custom(customGroup))
            } else {
                _selectedGroupOption = State(initialValue: .preset(.friend))
            }
        }
    }
    
    var allGroups: [AddRelationshipSheet.GroupOption] {
        var options: [AddRelationshipSheet.GroupOption] = Relationship.Group.allCases.map { .preset($0) }
        options.append(contentsOf: viewModel.customGroups.map { .custom($0) })
        return options
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                
                Picker("Group", selection: $selectedGroupOption) {
                    ForEach(allGroups, id: \.self) { option in
                        Text(option.name).tag(option)
                    }
                }
                
                DatePicker("Last Met",
                          selection: $lastMet,
                          displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                Picker("Meeting Frequency", selection: $intensity) {
                    ForEach(Relationship.MeetingFrequency.allCases, id: \.self) { frequency in
                        Text(frequency.rawValue)
                    }
                }
                
                Section {
                    Button("Delete Relationship", role: .destructive) {
                        viewModel.deleteRelationship(relationship)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Relationship")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let groupType: Relationship.GroupType
                        switch selectedGroupOption {
                        case .preset(let group):
                            groupType = .preset(group)
                        case .custom(let group):
                            groupType = .custom(group.name)
                        }
                        
                        viewModel.updateRelationship(
                            relationship,
                            newName: name,
                            newGroup: groupType,
                            newLastMet: lastMet,
                            newIntensity: intensity
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 