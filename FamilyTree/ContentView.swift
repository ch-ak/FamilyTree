import SwiftUI

struct ContentView: View {
    @StateObject private var wizardViewModel = CleanPersonFormViewModel()
    @StateObject private var dataSourceManager = DataSourceManager.shared

    var body: some View {
        TabView {
            ChatWizardView(viewModel: wizardViewModel)
                .tabItem {
                    Label("Update", systemImage: "message.and.waveform")
                }
            
            WhoAmIView()
                .tabItem {
                    Label("WHO", systemImage: "person.text.rectangle")
                }

            FamilyTreeTabView(wizardViewModel: wizardViewModel)
                .tabItem {
                    Label("My Tree", systemImage: "person.2.fill")
                }
            
            FullFamilyTreeTabView()
                .tabItem {
                    Label("Full Tree", systemImage: "tree.fill")
                }
            
            D3FamilyTreeTabView()
                .tabItem {
                    Label("D3 Tree", systemImage: "chart.bar.doc.horizontal")
                }
            
            JustTreeView()
                .tabItem {
                    Label("Just Tree", systemImage: "tree")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @StateObject private var dataSourceManager = DataSourceManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $dataSourceManager.isUsingMockData) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: dataSourceManager.isUsingMockData ? "theatermasks.fill" : "cylinder.fill")
                                    .foregroundStyle(dataSourceManager.isUsingMockData ? .orange : .blue)
                                Text("Use Mock Data")
                                    .font(.headline)
                            }
                            
                            Text(dataSourceManager.isUsingMockData
                                ? "Currently using 200 test people (1720-2020)"
                                : "Currently using Supabase database")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.orange)
                } header: {
                    Text("Data Source")
                } footer: {
                    Text("Toggle to test with 200 mock people across 10 generations (1720-2020) or use real database.")
                }
                
                if dataSourceManager.isUsingMockData {
                    Section {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundStyle(.green)
                            Text("Mock People")
                            Spacer()
                            Text("~200")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.orange)
                            Text("Year Range")
                            Spacer()
                            Text("1720 - 2020")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                                .foregroundStyle(.purple)
                            Text("Generations")
                            Spacer()
                            Text("10")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.blue)
                            Text("Relationships")
                            Spacer()
                            Text("~600")
                                .fontWeight(.semibold)
                        }
                    } header: {
                        Text("Mock Data Statistics")
                    } footer: {
                        Text("Mock data includes complete family trees with parents, siblings, spouses, and children across 10 generations.")
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text("About")
                        Spacer()
                        Text("Version 1.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.green)
                        Text("Developer")
                        Spacer()
                        Text("Chakri K.")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
