import SwiftUI

struct AddTouchPointSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    
    @State private var selectedRelationshipId: UUID?
    @State private var date = Date()
    @State private var notes = ""
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Person Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Person")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            ForEach(viewModel.relationships) { relationship in
                                Button {
                                    selectedRelationshipId = relationship.id
                                } label: {
                                    Text(relationship.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedRelationshipId.flatMap { id in
                                    viewModel.relationships.first { $0.id == id }?.name
                                } ?? "Select a person")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .font(AppTheme.Typography.body)
                            .foregroundColor(selectedRelationshipId == nil ? .secondary : .primary)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .glassBackground()
                        }
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        Button {
                            withAnimation {
                                showingDatePicker.toggle()
                            }
                        } label: {
                            HStack {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Image(systemName: "calendar")
                            }
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .glassBackground()
                        }
                        
                        if showingDatePicker {
                            DatePicker(
                                "Select date",
                                selection: $date,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            .glassBackground()
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onChange(of: date) { _ in
                                withAnimation {
                                    showingDatePicker = false
                                }
                            }
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $notes)
                            .font(AppTheme.Typography.body)
                            .frame(minHeight: 100)
                            .padding()
                            .glassBackground()
                            .scrollContentBackground(.hidden)
                    }
                }
                .padding(24)
            }
            .background(AppTheme.backgroundColor)
            .navigationTitle("Add TouchPoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let relationshipId = selectedRelationshipId {
                            // Update the model to include notes
                            viewModel.addTouchPoint(
                                relationshipId: relationshipId,
                                date: date,
                                notes: notes
                            )
                        }
                        dismiss()
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(selectedRelationshipId == nil ? .gray : AppTheme.primaryColor)
                    .disabled(selectedRelationshipId == nil)
                }
            }
        }
    }
} 