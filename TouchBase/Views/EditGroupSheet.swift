import SwiftUI

struct EditGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    let group: GroupOption
    
    @State private var name: String
    @State private var description: String
    
    init(viewModel: RelationshipsViewModel, group: GroupOption) {
        self.viewModel = viewModel
        self.group = group
        
        switch group {
        case .preset(let presetGroup):
            _name = State(initialValue: presetGroup.rawValue)
            _description = State(initialValue: "")
        case .custom(let customGroup):
            _name = State(initialValue: customGroup.name)
            _description = State(initialValue: customGroup.description)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        switch group {
                        case .preset(let presetGroup):
                            viewModel.updatePresetGroup(presetGroup, newName: name)
                        case .custom(let customGroup):
                            viewModel.updateCustomGroup(customGroup, newName: name, newDescription: description)
                        }
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 