import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedRelationships: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("People Involved") {
                    ForEach(viewModel.relationships) { relationship in
                        HStack {
                            Text(relationship.name)
                            Spacer()
                            if selectedRelationships.contains(relationship.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedRelationships.contains(relationship.id) {
                                selectedRelationships.remove(relationship.id)
                            } else {
                                selectedRelationships.insert(relationship.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = Task(
                            title: title,
                            description: description,
                            relationshipIds: Array(selectedRelationships),
                            createdAt: Date(),
                            isCompleted: false
                        )
                        viewModel.addTask(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
} 