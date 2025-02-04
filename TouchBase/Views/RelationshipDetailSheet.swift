import SwiftUI

struct RelationshipDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    let relationship: Relationship
    @State private var showingEditSheet = false
    
    var touchPoints: [TouchPoint] {
        viewModel.touchPoints
            .filter { $0.relationshipId == relationship.id }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Relationship Info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(relationship.name)
                                    .font(AppTheme.Typography.headline)
                                Text(relationship.group.name)
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                showingEditSheet = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                            .padding(8)
                            .contentShape(Rectangle())
                        }
                        .padding()
                        .glassBackground()
                        
                        // Meeting Frequency
                        HStack {
                            Label("Frequency", systemImage: "calendar.badge.clock")
                            Spacer()
                            Text(relationship.intensity.rawValue)
                        }
                        .font(AppTheme.Typography.subheadline)
                        .padding()
                        .glassBackground()
                    }
                    
                    // TouchPoints History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("History")
                            .font(AppTheme.Typography.headline)
                        
                        if touchPoints.isEmpty {
                            Text("No touch points recorded yet")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .glassBackground()
                        } else {
                            ForEach(touchPoints) { touchPoint in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(touchPoint.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(AppTheme.Typography.subheadline)
                                        Spacer()
                                        Text(touchPoint.date.formatted(date: .complete, time: .omitted))
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if !touchPoint.notes.isEmpty {
                                        Text(touchPoint.notes)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .glassBackground()
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundColor)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditRelationshipSheet(viewModel: viewModel, relationship: relationship)
            }
        }
    }
} 