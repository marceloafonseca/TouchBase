import SwiftUI

struct TasksView: View {
    @ObservedObject var viewModel: RelationshipsViewModel
    @State private var showingAddTask = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Tasks")
                        .font(AppTheme.Typography.title)
                        .padding(.horizontal, AppTheme.Layout.cardPadding)
                        .padding(.top, AppTheme.Layout.cardPadding)
                    
                    LazyVStack(spacing: AppTheme.Layout.cardPadding) {
                        ForEach(viewModel.tasks) { task in
                            TaskCard(viewModel: viewModel, task: task)
                        }
                    }
                    .padding(AppTheme.Layout.cardPadding)
                }
            }
            
            VStack {
                Spacer()
                Button {
                    showingAddTask = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Task")
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
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheet(viewModel: viewModel)
        }
    }
}

struct TaskCard: View {
    @ObservedObject var viewModel: RelationshipsViewModel
    let task: Task
    @State private var showingOptions = false
    
    var relatedRelationships: [Relationship] {
        viewModel.relationships.filter { task.relationshipIds.contains($0.id) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(AppTheme.Animation.spring) {
                    showingOptions.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .secondary)
                            
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                        }
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.primary)
                        
                        Text("\(relatedRelationships.count) people involved")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showingOptions ? 90 : 0))
                }
                .padding(AppTheme.Layout.cardPadding)
            }
            .glassBackground()
            
            if showingOptions {
                VStack(alignment: .leading, spacing: 12) {
                    Text(task.description)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(.primary)
                    
                    if !relatedRelationships.isEmpty {
                        Text("People Involved")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(relatedRelationships) { relationship in
                            Text(relationship.name)
                                .font(AppTheme.Typography.body)
                        }
                    }
                    
                    HStack {
                        Button {
                            viewModel.toggleTaskCompletion(task)
                        } label: {
                            Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.deleteTask(task)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .font(AppTheme.Typography.body)
                }
                .padding(AppTheme.Layout.cardPadding)
                .glassBackground()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
} 