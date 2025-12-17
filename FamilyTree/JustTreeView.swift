import SwiftUI
import Supabase

/// JustTreeView - Clean native SwiftUI family tree visualization
/// Fresh implementation with proper GoJS-style layout
struct JustTreeView: View {
    @StateObject private var dataSourceManager = DataSourceManager.shared
    
    @State private var allPeople: [PersonRecordDisplay] = []
    @State private var allRelationships: [RelationshipRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedRootId: UUID?
    @State private var layout: FamilyTreeLayout?
    
    // Layout spacing constants
    private let nodeWidth: CGFloat = 160
    private let nodeHeight: CGFloat = 70
    private let horizontalSpacing: CGFloat = 50
    private let verticalSpacing: CGFloat = 120
    private let spouseSpacing: CGFloat = 25
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading family tree...")
                            .foregroundStyle(.secondary)
                    }
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if allPeople.isEmpty {
                    emptyView
                } else if let layout = layout {
                    treeCanvas(layout: layout)
                } else {
                    Text("Select a person from the picker above")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Family Tree")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !allPeople.isEmpty {
                        rootSelector
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await loadTreeData() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadTreeData()
            }
            .onChange(of: dataSourceManager.isUsingMockData) { _, _ in
                Task { await loadTreeData() }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 70))
                .foregroundStyle(.blue.opacity(0.3))
            Text("No Family Data")
                .font(.title2.bold())
            Text("Add people using the Chat Wizard")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            Text("Error Loading Tree")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var rootSelector: some View {
        Picker("Root Person", selection: Binding(
            get: { selectedRootId ?? allPeople.first?.id },
            set: { newValue in
                selectedRootId = newValue
                Task { await buildLayout() }
            }
        )) {
            ForEach(allPeople, id: \.id) { person in
                Text("\(person.full_name) (\(person.birth_year))")
                    .tag(person.id as UUID?)
            }
        }
        .pickerStyle(.menu)
    }
    
    private func treeCanvas(layout: FamilyTreeLayout) -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                // Canvas for drawing lines
                Canvas { context, size in
                    // Draw spouse connections (pink horizontal lines)
                    for line in layout.spouseLines {
                        var path = Path()
                        path.move(to: line.start)
                        path.addLine(to: line.end)
                        context.stroke(path, with: .color(.pink), lineWidth: 2.5)
                    }
                    
                    // Draw parent-child connections (gray L-shaped lines)
                    for line in layout.parentChildLines {
                        var path = Path()
                        path.move(to: line.start)
                        
                        // Draw elbow connector
                        let midY = (line.start.y + line.end.y) / 2
                        path.addLine(to: CGPoint(x: line.start.x, y: midY))
                        path.addLine(to: CGPoint(x: line.end.x, y: midY))
                        path.addLine(to: line.end)
                        
                        context.stroke(path, with: .color(.gray.opacity(0.6)), lineWidth: 2)
                    }
                }
                .frame(width: layout.canvasWidth, height: layout.canvasHeight)
                
                // Person cards
                ForEach(layout.personCards) { card in
                    PersonCard(person: card.person)
                        .frame(width: nodeWidth, height: nodeHeight)
                        .position(x: card.x, y: card.y)
                }
            }
            .frame(width: layout.canvasWidth, height: layout.canvasHeight)
            .padding(50)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadTreeData() async {
        await MainActor.run { isLoading = true }
        
        do {
            if dataSourceManager.isUsingMockData {
                // Load from mock repository
                let mockRepo = MockFamilyRepository()
                let people = try await mockRepo.fetchAllPeople()
                let rels = try await mockRepo.fetchAllRelationships()
                
                await MainActor.run {
                    allPeople = people.map { PersonRecordDisplay(id: $0.id, full_name: $0.fullName, birth_year: $0.birthYear) }
                    allRelationships = rels.map { RelationshipRecord(id: $0.id, person_id: $0.personId, related_person_id: $0.relatedPersonId, type: $0.type.rawValue) }
                }
            } else {
                // Load from Supabase
                let people: [PersonRecordDisplay] = try await SupabaseManager.shared.client
                    .from("person")
                    .select("id,full_name,birth_year")
                    .order("birth_year", ascending: true)
                    .execute()
                    .value
                
                let rels: [RelationshipRecord] = try await SupabaseManager.shared.client
                    .from("relationship")
                    .select("id,person_id,related_person_id,type")
                    .execute()
                    .value
                
                await MainActor.run {
                    allPeople = people
                    allRelationships = rels
                }
            }
            
            // Set default root to first person
            await MainActor.run {
                if selectedRootId == nil, let firstPerson = allPeople.first {
                    selectedRootId = firstPerson.id
                }
                errorMessage = nil
            }
            
            await buildLayout()
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                print("❌ Error loading tree data: \(error)")
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - Layout Algorithm
    
    private func buildLayout() async {
        guard !allPeople.isEmpty, let rootId = selectedRootId else {
            await MainActor.run { layout = nil }
            return
        }
        
        print("\n🌲 ===== BUILDING TREE LAYOUT =====")
        print("🌲 Root: \(allPeople.first(where: { $0.id == rootId })?.full_name ?? "Unknown")")
        print("🌲 Total people: \(allPeople.count)")
        print("🌲 Total relationships: \(allRelationships.count)")
        
        // Build lookup maps
        var personById: [UUID: PersonRecordDisplay] = [:]
        var childrenOf: [UUID: [UUID]] = [:]
        var spousesOf: [UUID: Set<UUID>] = [:]
        
        for person in allPeople {
            personById[person.id] = person
        }
        
        for rel in allRelationships {
            switch rel.type {
            case "PARENT":
                // person_id is parent, related_person_id is child
                childrenOf[rel.person_id, default: []].append(rel.related_person_id)
            case "CHILD":
                // person_id is child, related_person_id is parent
                childrenOf[rel.related_person_id, default: []].append(rel.person_id)
            case "SPOUSE":
                spousesOf[rel.person_id, default: []].insert(rel.related_person_id)
                spousesOf[rel.related_person_id, default: []].insert(rel.person_id)
            default:
                break
            }
        }
        
        print("🌲 Children map: \(childrenOf.count) parents have children")
        print("🌲 Spouse map: \(spousesOf.count) people have spouses")
        
        // BFS to assign generation levels
        var levelMap: [Int: [UUID]] = [:]
        var personToLevel: [UUID: Int] = [:]
        var visited = Set<UUID>()
        var queue: [(id: UUID, level: Int)] = [(rootId, 0)]
        
        visited.insert(rootId)
        
        while !queue.isEmpty {
            let (personId, level) = queue.removeFirst()
            levelMap[level, default: []].append(personId)
            personToLevel[personId] = level
            
            let name = personById[personId]?.full_name ?? "?"
            print("🌲 Level \(level): \(name)")
            
            // Add spouse at same level
            if let spouses = spousesOf[personId] {
                for spouseId in spouses where !visited.contains(spouseId) {
                    visited.insert(spouseId)
                    levelMap[level, default: []].append(spouseId)
                    personToLevel[spouseId] = level
                    let spouseName = personById[spouseId]?.full_name ?? "?"
                    print("  🌲 + Spouse: \(spouseName)")
                }
            }
            
            // Add children at next level
            if let children = childrenOf[personId] {
                print("  🌲 Found \(children.count) children")
                for childId in children where !visited.contains(childId) {
                    visited.insert(childId)
                    queue.append((childId, level + 1))
                    let childName = personById[childId]?.full_name ?? "?"
                    print("  🌲   → Child: \(childName) at level \(level + 1)")
                }
            }
        }
        
        let totalLevels = levelMap.keys.max() ?? 0
        print("🌲 BFS complete: \(totalLevels + 1) generations, \(visited.count) people")
        
        // Position nodes level by level
        var cards: [PersonCardPosition] = []
        var positions: [UUID: CGPoint] = [:]
        
        for level in 0...totalLevels {
            guard let peopleInLevel = levelMap[level] else { continue }
            
            let yPos = CGFloat(level) * verticalSpacing + 100
            var xPos: CGFloat = 100
            var processedInLevel = Set<UUID>()
            
            print("🌲 Positioning Level \(level): \(peopleInLevel.count) people")
            
            for personId in peopleInLevel.sorted(by: { personById[$0]?.full_name ?? "" < personById[$1]?.full_name ?? "" }) {
                guard !processedInLevel.contains(personId),
                      let person = personById[personId] else { continue }
                
                // Check for spouse at same level
                let spouseCandidates = (spousesOf[personId] ?? [])
                    .filter { peopleInLevel.contains($0) && !processedInLevel.contains($0) }
                
                if let spouseId = spouseCandidates.first,
                   let spouse = personById[spouseId] {
                    // Couple: position side by side
                    let x1 = xPos + nodeWidth / 2
                    let x2 = x1 + nodeWidth + spouseSpacing
                    
                    cards.append(PersonCardPosition(id: personId, person: person, x: x1, y: yPos))
                    cards.append(PersonCardPosition(id: spouseId, person: spouse, x: x2, y: yPos))
                    
                    positions[personId] = CGPoint(x: x1, y: yPos)
                    positions[spouseId] = CGPoint(x: x2, y: yPos)
                    
                    processedInLevel.insert(personId)
                    processedInLevel.insert(spouseId)
                    
                    xPos = x2 + nodeWidth / 2 + horizontalSpacing
                    
                    print("  🌲 Couple: \(person.full_name) & \(spouse.full_name) at x=\(x1), x=\(x2)")
                } else {
                    // Single person
                    let x = xPos + nodeWidth / 2
                    
                    cards.append(PersonCardPosition(id: personId, person: person, x: x, y: yPos))
                    positions[personId] = CGPoint(x: x, y: yPos)
                    
                    processedInLevel.insert(personId)
                    xPos = x + nodeWidth / 2 + horizontalSpacing
                    
                    print("  🌲 Single: \(person.full_name) at x=\(x)")
                }
            }
        }
        
        print("🌲 Positioned \(cards.count) person cards")
        
        // Create spouse connection lines
        var spouseLines: [TreeLine] = []
        var processedPairs = Set<String>()
        
        for rel in allRelationships where rel.type == "SPOUSE" {
            let pairKey = [rel.person_id.uuidString, rel.related_person_id.uuidString].sorted().joined(separator: "-")
            guard !processedPairs.contains(pairKey),
                  let pos1 = positions[rel.person_id],
                  let pos2 = positions[rel.related_person_id],
                  personToLevel[rel.person_id] == personToLevel[rel.related_person_id] else { continue }
            
            processedPairs.insert(pairKey)
            
            let leftX = min(pos1.x, pos2.x) + nodeWidth / 2
            let rightX = max(pos1.x, pos2.x) - nodeWidth / 2
            
            spouseLines.append(TreeLine(
                start: CGPoint(x: leftX, y: pos1.y),
                end: CGPoint(x: rightX, y: pos1.y)
            ))
        }
        
        print("🌲 Created \(spouseLines.count) spouse lines")
        
        // Create parent-child connection lines
        var parentChildLines: [TreeLine] = []
        
        for (parentId, children) in childrenOf {
            guard let parentPos = positions[parentId] else { continue }
            
            // Find spouse at same level to draw from center of couple
            let spousePositions = (spousesOf[parentId] ?? [])
                .compactMap { positions[$0] }
                .filter { $0.y == parentPos.y }
            
            let startX: CGFloat
            if let spousePos = spousePositions.first {
                startX = (parentPos.x + spousePos.x) / 2
            } else {
                startX = parentPos.x
            }
            
            let startY = parentPos.y + nodeHeight / 2
            
            for childId in children {
                guard let childPos = positions[childId] else { continue }
                
                parentChildLines.append(TreeLine(
                    start: CGPoint(x: startX, y: startY),
                    end: CGPoint(x: childPos.x, y: childPos.y - nodeHeight / 2)
                ))
            }
        }
        
        print("🌲 Created \(parentChildLines.count) parent-child lines")
        
        // Calculate canvas size
        let maxX = cards.map { $0.x + nodeWidth / 2 }.max() ?? 800
        let maxY = cards.map { $0.y + nodeHeight / 2 }.max() ?? 600
        
        let finalLayout = FamilyTreeLayout(
            personCards: cards,
            spouseLines: spouseLines,
            parentChildLines: parentChildLines,
            canvasWidth: maxX + 200,
            canvasHeight: maxY + 200
        )
        
        print("🌲 Layout complete: \(finalLayout.canvasWidth) x \(finalLayout.canvasHeight)")
        print("🌲 ===== TREE BUILT SUCCESSFULLY =====\n")
        
        await MainActor.run {
            layout = finalLayout
        }
    }
}

// MARK: - Data Models

fileprivate struct FamilyTreeLayout {
    let personCards: [PersonCardPosition]
    let spouseLines: [TreeLine]
    let parentChildLines: [TreeLine]
    let canvasWidth: CGFloat
    let canvasHeight: CGFloat
}

fileprivate struct PersonCardPosition: Identifiable {
    let id: UUID
    let person: PersonRecordDisplay
    let x: CGFloat
    let y: CGFloat
}

fileprivate struct TreeLine {
    let start: CGPoint
    let end: CGPoint
}

fileprivate struct PersonCard: View {
    let person: PersonRecordDisplay
    
    var body: some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(person.full_name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                
                Text("Born \(person.birth_year)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    JustTreeView()
}
