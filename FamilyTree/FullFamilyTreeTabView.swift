import SwiftUI
import Supabase

struct FullFamilyTreeTabView: View {
    @State private var allPeople: [PersonRecordDisplay] = []
    @State private var allRelationships: [RelationshipRecord] = []
    @State private var isLoading = false
    @State private var loadError: String?
    @State private var searchText = ""
    @State private var selectedGenerationFilter: GenerationFilter = .all
    @StateObject private var dataSourceManager = DataSourceManager.shared
    
    enum GenerationFilter: String, CaseIterable {
        case all = "All Generations"
        case old = "Before 1850"
        case mid = "1850-1950"
        case recent = "After 1950"
    }
    
    var filteredPeople: [PersonRecordDisplay] {
        var filtered = allPeople
        
        // Apply generation filter
        switch selectedGenerationFilter {
        case .all:
            break
        case .old:
            filtered = filtered.filter { $0.birth_year < 1850 }
        case .mid:
            filtered = filtered.filter { $0.birth_year >= 1850 && $0.birth_year < 1950 }
        case .recent:
            filtered = filtered.filter { $0.birth_year >= 1950 }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.full_name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading complete family tree...")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if allPeople.isEmpty {
                    emptyStateView
                } else {
                    treeListView
                }
            }
            .navigationTitle("Complete Family Tree")
            .searchable(text: $searchText, prompt: "Search family members")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Filter by Generation", selection: $selectedGenerationFilter) {
                            ForEach(GenerationFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: selectedGenerationFilter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await loadCompleteTree() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
        }
        .task {
            await loadCompleteTree()
        }
        .onChange(of: dataSourceManager.isUsingMockData) { _, _ in
            Task { await loadCompleteTree() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataSourceChanged)) { _ in
            Task { await loadCompleteTree() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PersonAdded"))) { _ in
            print("🔔 PersonAdded notification received - reloading Full Tree")
            Task { await loadCompleteTree() }
        }
        .overlay(alignment: .top) {
            if let error = loadError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("No Family Data Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Toggle mock data in Settings or add family members in the Update tab")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var treeListView: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(.blue)
                    Text("Total People: \(filteredPeople.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundStyle(.green)
                    Text("Total Relationships: \(allRelationships.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.orange)
                    Text("Year Range: \(yearRange)")
                        .fontWeight(.semibold)
                }
                
                if selectedGenerationFilter != .all {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundStyle(.purple)
                        Text("Filtered: \(selectedGenerationFilter.rawValue)")
                            .fontWeight(.semibold)
                    }
                }
            } header: {
                Text("Family Tree Statistics")
            }
            
            Section {
                ForEach(filteredPeople) { person in
                    PersonRowView(person: person, relationships: relationshipsFor(person))
                }
            } header: {
                Text("All Family Members (\(filteredPeople.count))")
            }
        }
    }
    
    private var yearRange: String {
        let years = allPeople.map { $0.birth_year }
        guard let min = years.min(), let max = years.max() else { return "N/A" }
        return "\(min) - \(max)"
    }
    
    private func relationshipsFor(_ person: PersonRecordDisplay) -> [RelationshipInfo] {
        // Get relationships where this person is the source (person_id)
        let outgoingRelationships = allRelationships
            .filter { $0.person_id == person.id }
            .compactMap { rel -> RelationshipInfo? in
                guard let relatedPerson = allPeople.first(where: { $0.id == rel.related_person_id }) else {
                    return nil
                }
                return RelationshipInfo(type: rel.type, person: relatedPerson)
            }
        
        // Get relationships where this person is the target (related_person_id)
        // These need to be inverted to show from this person's perspective
        let incomingRelationships = allRelationships
            .filter { $0.related_person_id == person.id }
            .compactMap { rel -> RelationshipInfo? in
                guard let relatedPerson = allPeople.first(where: { $0.id == rel.person_id }) else {
                    return nil
                }
                
                // Invert the relationship type to show from current person's perspective
                let invertedType: String
                switch rel.type {
                case "PARENT":
                    invertedType = "CHILD"  // If someone has me as PARENT, they are my CHILD
                case "CHILD":
                    invertedType = "PARENT" // If someone has me as CHILD, they are my PARENT
                case "SPOUSE":
                    invertedType = "SPOUSE" // SPOUSE is symmetric
                case "SIBLING":
                    invertedType = "SIBLING" // SIBLING is symmetric
                default:
                    invertedType = rel.type
                }
                
                return RelationshipInfo(type: invertedType, person: relatedPerson)
            }
        
        // Combine both sets
        let allRelationships = outgoingRelationships + incomingRelationships
        
        // Remove duplicates: if same person appears multiple times with same relationship type, keep only one
        var seen = Set<String>()
        var uniqueRelationships: [RelationshipInfo] = []
        
        for rel in allRelationships {
            let key = "\(rel.type)-\(rel.person.id.uuidString)"
            if !seen.contains(key) {
                seen.insert(key)
                uniqueRelationships.append(rel)
            }
        }
        
        return uniqueRelationships
    }
    
    private func loadCompleteTree() async {
        print("🔄 Starting loadCompleteTree - isUsingMock: \(dataSourceManager.isUsingMockData)")
        
        await MainActor.run {
            isLoading = true
            loadError = nil
        }
        
        defer {
            Task {
                await MainActor.run { isLoading = false }
            }
        }
        
        do {
            let isUsingMock = dataSourceManager.isUsingMockData
            print("📊 Loading data - Mock: \(isUsingMock)")
            
            if isUsingMock {
                // Load from MockFamilyRepository
                print("🎭 Loading mock data...")
                let mockRepo = MockFamilyRepository()
                let mockPeople = try await mockRepo.fetchAllPeople()
                let mockRelationships = try await mockRepo.fetchAllRelationships()
                
                print("✅ Mock data loaded: \(mockPeople.count) people, \(mockRelationships.count) relationships")
                
                await MainActor.run {
                    allPeople = mockPeople.map { person in
                        PersonRecordDisplay(
                            id: person.id,
                            full_name: person.fullName,
                            birth_year: person.birthYear
                        )
                    }
                    
                    allRelationships = mockRelationships.map { rel in
                        RelationshipRecord(
                            id: rel.id,
                            person_id: rel.personId,
                            related_person_id: rel.relatedPersonId,
                            type: rel.type.rawValue
                        )
                    }
                }
                
                print("✅ UI updated with mock data")
            } else {
                // Load from Supabase
                print("💾 Loading from Supabase...")
                let people: [PersonRecordDisplay] = try await SupabaseManager.shared.client
                    .from("person")
                    .select("id,full_name,birth_year")
                    .order("birth_year", ascending: true)
                    .execute()
                    .value
                
                let relationships: [RelationshipRecord] = try await SupabaseManager.shared.client
                    .from("relationship")
                    .select("id,person_id,related_person_id,type")
                    .execute()
                    .value
                
                print("✅ Supabase data loaded: \(people.count) people, \(relationships.count) relationships")
                
                await MainActor.run {
                    allPeople = people
                    allRelationships = relationships
                }
            }
            
        } catch {
            print("❌ Error loading tree: \(error)")
            await MainActor.run {
                loadError = "Failed to load tree: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Data Models

struct RelationshipRecord: Identifiable, Decodable {
    let id: UUID
    let person_id: UUID
    let related_person_id: UUID
    let type: String
}

struct RelationshipInfo {
    let type: String
    let person: PersonRecordDisplay
}

// MARK: - Person Row View

struct PersonRowView: View {
    let person: PersonRecordDisplay
    let relationships: [RelationshipInfo]
    @State private var isExpanded = false
    
    private var parents: [PersonRecordDisplay] {
        relationships.filter { $0.type == "PARENT" }.map { $0.person }
    }
    
    private var children: [PersonRecordDisplay] {
        relationships.filter { $0.type == "CHILD" }.map { $0.person }
    }
    
    private var siblings: [PersonRecordDisplay] {
        relationships.filter { $0.type == "SIBLING" }.map { $0.person }
    }
    
    private var spouses: [PersonRecordDisplay] {
        relationships.filter { $0.type == "SPOUSE" }.map { $0.person }
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                if !parents.isEmpty {
                    RelationshipSection(title: "Parents", people: parents, color: .purple)
                }
                
                if !spouses.isEmpty {
                    RelationshipSection(title: "Spouse(s)", people: spouses, color: .pink)
                }
                
                if !siblings.isEmpty {
                    RelationshipSection(title: "Siblings", people: siblings, color: .green)
                }
                
                if !children.isEmpty {
                    RelationshipSection(title: "Children", people: children, color: .orange)
                }
                
                if relationships.isEmpty {
                    Text("No relationships recorded yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            .padding(.vertical, 8)
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(person.full_name)
                        .font(.headline)
                    
                    HStack {
                        Text("Born \(String(person.birth_year))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if !relationships.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                    .font(.caption)
                                Text("\(relationships.count)")
                                    .font(.caption)
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
    }
}

struct RelationshipSection: View {
    let title: String
    let people: [PersonRecordDisplay]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            ForEach(people) { person in
                HStack(spacing: 8) {
                    Text("•")
                        .foregroundStyle(color)
                    Text(person.full_name)
                        .font(.subheadline)
                    Text("(\(String(person.birth_year)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 16)
            }
        }
    }
}

#Preview {
    FullFamilyTreeTabView()
}
