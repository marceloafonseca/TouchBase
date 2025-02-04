import SwiftUI

struct AddRelationshipSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RelationshipsViewModel
    
    @State private var name = ""
    @State private var selectedGroupOption: GroupOption = .preset(.friend)
    @State private var lastMet = Date()
    @State private var intensity = Relationship.MeetingFrequency.monthly
    @State private var showingDatePicker = false
    
    var allGroups: [GroupOption] {
        var options = Relationship.Group.allCases.map { GroupOption.preset($0) }
        options.append(contentsOf: viewModel.customGroups.map { GroupOption.custom($0) })
        return options
    }
    
    enum GroupOption: Hashable {
        case preset(Relationship.Group)
        case custom(CustomGroup)
        
        var name: String {
            switch self {
            case .preset(let group): return group.rawValue
            case .custom(let group): return group.name
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .preset(let group):
                hasher.combine(0)
                hasher.combine(group)
            case .custom(let group):
                hasher.combine(1)
                hasher.combine(group)
            }
        }
        
        static func == (lhs: GroupOption, rhs: GroupOption) -> Bool {
            switch (lhs, rhs) {
            case (.preset(let l), .preset(let r)): return l == r
            case (.custom(let l), .custom(let r)): return l == r
            default: return false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter name", text: $name)
                            .font(AppTheme.Typography.body)
                            .textFieldStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .glassBackground()
                    }
                    
                    // Group Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        Menu {
                            ForEach(allGroups, id: \.self) { option in
                                Button {
                                    selectedGroupOption = option
                                } label: {
                                    Text(option.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedGroupOption.name)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .glassBackground()
                        }
                    }
                    
                    // Last Met Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Met")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        Button {
                            withAnimation {
                                showingDatePicker.toggle()
                            }
                        } label: {
                            HStack {
                                Text(lastMet.formatted(date: .abbreviated, time: .omitted))
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
                                selection: $lastMet,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            .glassBackground()
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onChange(of: lastMet) { _ in
                                withAnimation {
                                    showingDatePicker = false
                                }
                            }
                        }
                    }
                    
                    // Meeting Frequency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meeting Frequency")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $intensity) {
                            ForEach(Relationship.MeetingFrequency.allCases, id: \.self) { frequency in
                                VStack {
                                    Text(frequency.rawValue)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 44)
                                .tag(frequency)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                        .glassBackground()
                    }
                }
                .padding(24)
            }
            .background(AppTheme.backgroundColor)
            .navigationTitle("Add Relationship")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let groupType: Relationship.GroupType
                        switch selectedGroupOption {
                        case .preset(let group):
                            groupType = .preset(group)
                        case .custom(let group):
                            groupType = .custom(group.name)
                        }
                        
                        let relationship = Relationship(
                            name: name,
                            group: groupType,
                            lastMet: lastMet,
                            intensity: intensity
                        )
                        viewModel.addRelationship(relationship)
                        dismiss()
                    }
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(name.isEmpty ? .gray : AppTheme.primaryColor)
                    .disabled(name.isEmpty)
                }
            })
        }
    }
} 