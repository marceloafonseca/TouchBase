import SwiftUI

struct GroupsView: View {
    @ObservedObject var viewModel: RelationshipsViewModel
    @State private var groupToEdit: GroupOption?
    @State private var showingAddGroup = false
    
    var allGroups: [GroupOption] {
        var groups = Relationship.Group.allCases.map { GroupOption.preset($0) }
        groups.append(contentsOf: viewModel.customGroups.map { GroupOption.custom($0) })
        return groups
    }
    
    var groupedRelationships: [(GroupOption, [Relationship])] {
        allGroups.map { group in
            let relationships = viewModel.relationships.filter { relationship in
                switch (group, relationship.group) {
                case (.preset(let groupType), .preset(let relGroup)): 
                    return groupType == relGroup
                case (.custom(let customGroup), .custom(let name)):
                    return customGroup.name == name
                default:
                    return false
                }
            }
            return (group, relationships)
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Groups")
                        .font(AppTheme.Typography.title)
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                        .padding(.top, AppTheme.Layout.cardPadding)
                    
                    LazyVStack(spacing: AppTheme.Layout.cardPadding) {
                        ForEach(groupedRelationships, id: \.0) { group, relationships in
                            GroupCard(
                                group: group,
                                relationshipCount: relationships.count,
                                relationships: relationships,
                                onEdit: {
                                    groupToEdit = group
                                },
                                onDelete: {
                                    deleteGroup(group)
                                }
                            )
                        }
                    }
                    .padding(AppTheme.Layout.cardPadding)
                }
            }
            
            VStack {
                Spacer()
                Button {
                    showingAddGroup = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Group")
                    }
                    .frame(height: AppTheme.Layout.buttonHeight)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: AppTheme.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppTheme.Layout.buttonHeight / 2)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Layout.cardPadding)
                    .padding(.bottom, AppTheme.Layout.cardPadding)
                }
            }
        }
        .background(AppTheme.backgroundColor)
        .sheet(item: $groupToEdit) { group in
            EditGroupSheet(viewModel: viewModel, group: group)
        }
        .sheet(isPresented: $showingAddGroup) {
            AddGroupSheet(viewModel: viewModel)
        }
    }
    
    private func deleteGroup(_ group: GroupOption) {
        switch group {
        case .preset(let presetGroup):
            viewModel.moveRelationshipsFromPresetGroup(presetGroup.rawValue)
        case .custom(let customGroup):
            viewModel.deleteCustomGroup(customGroup)
        }
    }
}

struct GroupCard: View {
    let group: GroupOption
    let relationshipCount: Int
    let relationships: [Relationship]
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showingRelationships = false
    @State private var showingOptions = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(AppTheme.Animation.spring) {
                    showingOptions.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Layout.cardPadding) {
                    // Left side with icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: AppTheme.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)
                        
                        Text("\(relationshipCount)")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                    }
                    
                    // Middle with name
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Right side with chevron
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showingOptions ? 90 : 0))
                }
                .padding(AppTheme.Layout.cardPadding)
            }
            .glassBackground()
            
            if showingOptions {
                VStack(spacing: 0) {
                    Button {
                        withAnimation(AppTheme.Animation.spring) {
                            showingRelationships.toggle()
                        }
                    } label: {
                        HStack {
                            Text("View Relationships")
                                .font(AppTheme.Typography.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(showingRelationships ? 90 : 0))
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                    
                    Button {
                        onEdit()
                    } label: {
                        HStack {
                            Text("Edit")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                    
                    Button {
                        onDelete()
                    } label: {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                        .padding(.vertical, 12)
                    }
                }
                .glassBackground()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if showingRelationships {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(relationships) { relationship in
                        RelationshipRow(relationship: relationship)
                            .padding(.horizontal, AppTheme.Layout.cardPadding)
                    }
                }
                .padding(.vertical, 8)
                .glassBackground()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct RelationshipRow: View {
    let relationship: Relationship
    
    var body: some View {
        HStack {
            Text(relationship.name)
                .font(AppTheme.Typography.body)
            
            Spacer()
            
            Text(relationship.lastMet.formatted(date: .abbreviated, time: .omitted))
                .font(AppTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
} 
