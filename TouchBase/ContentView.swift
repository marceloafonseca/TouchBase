//
//  ContentView.swift
//  TouchBase
//
//  Created by Marcelo Afonseca on 26/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var relationshipsViewModel = RelationshipsViewModel()
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var showingEditSheet: Relationship?
    @State private var showingTouchPointSheet = false
    @State private var searchText = ""
    @State private var showingDetailSheet: Relationship?
    
    var filteredRelationships: [Relationship] {
        if searchText.isEmpty {
            return relationshipsViewModel.sortedRelationships
        }
        return relationshipsViewModel.sortedRelationships.filter { relationship in
            relationship.name.localizedCaseInsensitiveContains(searchText) ||
            relationship.group.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Weekly Tasks Section
                        if !relationshipsViewModel.weeklyTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Hey! You should reach out to")
                                    .font(AppTheme.Typography.headline)
                                    .padding(.horizontal, AppTheme.Layout.cardPadding)
                                    .padding(.top, AppTheme.Layout.cardPadding)
                                
                                ForEach(relationshipsViewModel.weeklyTasks) { relationship in
                                    RelationshipCard(relationship: relationship) {
                                        showingDetailSheet = relationship
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingTouchPointSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add TouchPoint")
                            }
                        }
                        .primaryButton()
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .background(AppTheme.backgroundColor)
                .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tasks Tab
            TasksView(viewModel: relationshipsViewModel)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(1)
            
            // Relationships Tab
            NavigationStack {
                ZStack {
                    VStack(spacing: 0) {
                        SearchBar(text: $searchText)
                            .padding()
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredRelationships) { relationship in
                                    RelationshipCard(relationship: relationship) {
                                        showingDetailSheet = relationship
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    VStack {
                        Spacer()
                        Button {
                            showingAddSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Relationship")
                            }
                        }
                        .primaryButton()
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .background(AppTheme.backgroundColor)
                .navigationTitle("Relationships")
            }
            .tabItem {
                Label("Relationships", systemImage: "person.2.fill")
            }
            .tag(2)
            
            // Groups Tab
            GroupsView(viewModel: relationshipsViewModel)
                .tabItem {
                    Label("Groups", systemImage: "folder")
                }
                .tag(3)
        }
        .tint(AppTheme.primaryColor)
        .sheet(isPresented: $showingAddSheet) {
            AddRelationshipSheet(viewModel: relationshipsViewModel)
        }
        .sheet(item: $showingEditSheet) { relationship in
            EditRelationshipSheet(viewModel: relationshipsViewModel, relationship: relationship)
        }
        .sheet(isPresented: $showingTouchPointSheet) {
            AddTouchPointSheet(viewModel: relationshipsViewModel)
        }
        .sheet(item: $showingDetailSheet) { relationship in
            RelationshipDetailSheet(viewModel: relationshipsViewModel, relationship: relationship)
        }
    }
}

#Preview {
    ContentView()
}
