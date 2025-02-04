import SwiftUI

struct AddGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Name")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter group name", text: $name)
                            .font(AppTheme.Typography.body)
                            .textFieldStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .glassBackground()
                    }
                }
                .padding(24)
            }
            .background(AppTheme.backgroundColor)
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let group = CustomGroup(
                            name: name,
                            description: ""  // Empty description
                        )
                        viewModel.addCustomGroup(group)
                        dismiss()
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(name.isEmpty ? .gray : AppTheme.primaryColor)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 