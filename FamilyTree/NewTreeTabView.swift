import SwiftUI
import Supabase

/// NewTreeTabView - Native SwiftUI family tree visualization
/// Displays a hierarchical tree with proper generation levels, spouse positioning, and parent-child connections
struct NewTreeTabView: View {
@StateObject private var dataSourceManager = DataSourceManager.shared

@State private var allPeople: [PersonRecordDisplay] = []
@State private var allRelationships: [RelationshipRecord] = []
@State private var isLoading = false
@State private var loadError: String?
@State private var rootPersonId: UUID?
@State private var treeLayout: TreeLayout?

// Layout constants
private let nodeWidth: CGFloat = 160
private let nodeHeight: CGFloat = 60
private let horizontalGap: CGFloat = 40
private let verticalGap: CGFloat = 100
private let spouseGap: CGFloat = 20

var body: some View {
    NavigationStack {
        ZStack {
            if isLoading {
                ProgressView("Loading family tree...")
            } else if allPeople.isEmpty {
                emptyStateView
            } else if let layout = treeLayout {
                treeView(layout: layout)
            } else {
                Text("Select a root person to view tree")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Family Tree")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !allPeople.isEmpty {
                    rootPersonPicker
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { Task { await loadData() } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task { await loadData() }
        .onChange(of: dataSourceManager.isUsingMockData) { _, _ in
            Task { await loadData() }
        }
    }
}

private var emptyStateView: some View {
    VStack(spacing: 16) {
        Image(systemName: "tree.fill")
            .font(.system(size: 60))
            .foregroundStyle(.secondary)
        Text("No family data available")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}

private var rootPersonPicker: some View {
    Picker("Root", selection: Binding(
        get: { rootPersonId ?? allPeople.first?.id },
        set: { newId in
            rootPersonId = newId
            Task { await computeLayout() }
        }
    )) {
        ForEach(allPeople, id: \.id) { person in
            Text(person.full_name).tag(person.id as UUID?)
        }
    }
    .pickerStyle(.menu)
}

private func treeView(layout: TreeLayout) -> some View {
    ScrollView([.horizontal, .vertical]) {
        ZStack(alignment: .topLeading) {
            // Draw connections using Canvas
            Canvas { context, size in
                // Draw spouse connections (pink horizontal lines)
                for connection in layout.spouseConnections {
                    var path = Path()
                    path.move(to: connection.from)
                    path.addLine(to: connection.to)
                    context.stroke(path, with: .color(.pink), lineWidth: 2)
                }
                
                // Draw parent-child connections (gray elbow lines)
                for connection in layout.parentChildConnections {
                    var path = Path()
                    path.move(to: connection.from)
                    let midY = (connection.from.y + connection.to.y) / 2
                    path.addLine(to: CGPoint(x: connection.from.x, y: midY))
                    path.addLine(to: CGPoint(x: connection.to.x, y: midY))
                    path.addLine(to: connection.to)
                    context.stroke(path, with: .color(.gray.opacity(0.5)), lineWidth: 1.5)
                }
            }
            .frame(width: layout.totalWidth, height: layout.totalHeight)
            
            // Draw person nodes
            ForEach(layout.nodes) { node in
                PersonNodeView(person: node.person)
                    .frame(width: nodeWidth, height: nodeHeight)
                    .position(x: node.x, y: node.y)
            }
        }
        .frame(width: layout.totalWidth, height: layout.totalHeight)
        .padding(40)
    }
}

// MARK: - Data Loading

private func loadData() async {
    isLoading = true
    loadError = nil
    
    do {
        if dataSourceManager.isUsingMockData {
            let mockRepo = MockFamilyRepository()
            let people = try await mockRepo.fetchAllPeople()
            let relationships = try await mockRepo.fetchAllRelationships()
            
            await MainActor.run {
                allPeople = people.map { PersonRecordDisplay(id: $0.id, full_name: $0.fullName, birth_year: $0.birthYear) }
                allRelationships = relationships.map { RelationshipRecord(id: $0.id, person_id: $0.personId, related_person_id: $0.relatedPersonId, type: $0.type.rawValue) }
            }
        } else {
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
            
            await MainActor.run {
                allPeople = people
                allRelationships = relationships
            }
        }
        
        await MainActor.run {
            if rootPersonId == nil {
                rootPersonId = allPeople.first?.id
            }
        }
        
        await computeLayout()
        
    } catch {
        await MainActor.run {
            loadError = error.localizedDescription
        }
        print("❌ Error loading tree: \(error)")
    }
    
    await MainActor.run {
        isLoading = false
    }
}

// MARK: - Layout Algorithm

private func computeLayout() async {
    guard !allPeople.isEmpty,
          let rootId = rootPersonId else {
        await MainActor.run {
            treeLayout = nil
        }
        return
    }
    
    // Build relationship maps
    var childrenMap: [UUID: [UUID]] = [:]
    var spouseMap: [UUID: Set<UUID>] = [:]
    var personLookup: [UUID: PersonRecordDisplay] = [:]
    
    for person in allPeople {
        personLookup[person.id] = person
    }
    
    for rel in allRelationships {
        switch rel.type {
        case "PARENT":
            childrenMap[rel.person_id, default: []].append(rel.related_person_id)
        case "CHILD":
            childrenMap[rel.related_person_id, default: []].append(rel.person_id)
        case "SPOUSE":
            spouseMap[rel.person_id, default: []].insert(rel.related_person_id)
            spouseMap[rel.related_person_id, default: []].insert(rel.person_id)
        default:
            break
        }
    }
    
        // BFS to assign generation levels
        var levels: [Int: [UUID]] = [:]
        var personLevel: [UUID: Int] = [:]
        var visited = Set<UUID>()
        var queue: [(UUID, Int)] = [(rootId, 0)]
        
        visited.insert(rootId)
        
        print("🌳 Starting BFS from root: \(personLookup[rootId]?.full_name ?? "Unknown")")
        print("🌳 Total people: \(personLookup.count), Total relationships: \(allRelationships.count)")
        
        while !queue.isEmpty {
            let (personId, level) = queue.removeFirst()
            levels[level, default: []].append(personId)
            personLevel[personId] = level
            
            let personName = personLookup[personId]?.full_name ?? "Unknown"
            print("🌳 Level \(level): \(personName)")
            
            // Add spouse at same level
            if let spouses = spouseMap[personId] {
                print("  🌳 Found \(spouses.count) spouse(s) for \(personName)")
                for spouseId in spouses where !visited.contains(spouseId) {
                    visited.insert(spouseId)
                    levels[level, default: []].append(spouseId)
                    personLevel[spouseId] = level
                    let spouseName = personLookup[spouseId]?.full_name ?? "Unknown"
                    print("  🌳   Added spouse: \(spouseName) at level \(level)")
                }
            }
            
            // Add children at next level
            if let children = childrenMap[personId] {
                print("  🌳 Found \(children.count) child(ren) for \(personName)")
                for childId in children where !visited.contains(childId) {
                    visited.insert(childId)
                    queue.append((childId, level + 1))
                    let childName = personLookup[childId]?.full_name ?? "Unknown"
                    print("  🌳   Added child: \(childName) at level \(level + 1)")
                }
            }
        }
        
        print("🌳 BFS Complete! Found \(levels.count) levels with \(visited.count) people")
    
    // Layout nodes level by level
    var nodes: [NativeTreeNode] = []
    var nodePositions: [UUID: CGPoint] = [:]
    
    let maxLevel = levels.keys.max() ?? 0
    
    for level in 0...maxLevel {
        guard let peopleAtLevel = levels[level] else { continue }
        
        var xOffset: CGFloat = 50
        let yPosition = CGFloat(level) * (nodeHeight + verticalGap) + 50
        
        var processedAtLevel = Set<UUID>()
        
        for personId in peopleAtLevel.sorted(by: { personLookup[$0]?.full_name ?? "" < personLookup[$1]?.full_name ?? "" }) {
            guard !processedAtLevel.contains(personId),
                  let person = personLookup[personId] else { continue }
            
            // Check if this person has a spouse at the same level
            let spousesAtLevel = (spouseMap[personId] ?? [])
                .filter { peopleAtLevel.contains($0) && !processedAtLevel.contains($0) }
            
            if let spouseId = spousesAtLevel.first,
               let spouse = personLookup[spouseId] {
                // Position couple side by side
                let person1X = xOffset + nodeWidth / 2
                let person2X = person1X + nodeWidth + spouseGap
                
                nodes.append(NativeTreeNode(id: personId, person: person, x: person1X, y: yPosition))
                nodes.append(NativeTreeNode(id: spouseId, person: spouse, x: person2X, y: yPosition))
                
                nodePositions[personId] = CGPoint(x: person1X, y: yPosition)
                nodePositions[spouseId] = CGPoint(x: person2X, y: yPosition)
                
                processedAtLevel.insert(personId)
                processedAtLevel.insert(spouseId)
                
                xOffset = person2X + nodeWidth / 2 + horizontalGap
            } else {
                // Single person
                let personX = xOffset + nodeWidth / 2
                
                nodes.append(NativeTreeNode(id: personId, person: person, x: personX, y: yPosition))
                nodePositions[personId] = CGPoint(x: personX, y: yPosition)
                
                processedAtLevel.insert(personId)
                xOffset = personX + nodeWidth / 2 + horizontalGap
            }
        }
    }
    
    // Create spouse connections
    var spouseConnections: [Connection] = []
    var processedSpousePairs = Set<String>()
    
    for rel in allRelationships where rel.type == "SPOUSE" {
        let key = [rel.person_id.uuidString, rel.related_person_id.uuidString].sorted().joined(separator: "-")
        guard !processedSpousePairs.contains(key),
              let pos1 = nodePositions[rel.person_id],
              let pos2 = nodePositions[rel.related_person_id],
              personLevel[rel.person_id] == personLevel[rel.related_person_id] else { continue }
        
        processedSpousePairs.insert(key)
        
        let leftX = min(pos1.x, pos2.x) + nodeWidth / 2
        let rightX = max(pos1.x, pos2.x) - nodeWidth / 2
        let y = pos1.y
        
        spouseConnections.append(Connection(
            from: CGPoint(x: leftX, y: y),
            to: CGPoint(x: rightX, y: y)
        ))
    }
    
    // Create parent-child connections
    var parentChildConnections: [Connection] = []
    
    for (parentId, children) in childrenMap {
        guard let parentPos = nodePositions[parentId] else { continue }
        
        // Find if parent has spouse at same level
        let parentSpouses = (spouseMap[parentId] ?? [])
            .compactMap { nodePositions[$0] }
            .filter { $0.y == parentPos.y }
        
        let fromX: CGFloat
        if let spousePos = parentSpouses.first {
            // Connect from center between couple
            fromX = (parentPos.x + spousePos.x) / 2
        } else {
            // Connect from single parent
            fromX = parentPos.x
        }
        
        let fromY = parentPos.y + nodeHeight / 2
        
        for childId in children {
            guard let childPos = nodePositions[childId] else { continue }
            
            parentChildConnections.append(Connection(
                from: CGPoint(x: fromX, y: fromY),
                to: CGPoint(x: childPos.x, y: childPos.y - nodeHeight / 2)
            ))
        }
    }
    
    // Calculate total dimensions
    let maxX = nodes.map { $0.x + nodeWidth / 2 }.max() ?? 600
    let maxY = nodes.map { $0.y + nodeHeight / 2 }.max() ?? 400
    
    let layout = TreeLayout(
        nodes: nodes,
        spouseConnections: spouseConnections,
        parentChildConnections: parentChildConnections,
        totalWidth: maxX + 100,
        totalHeight: maxY + 100
    )
    
    await MainActor.run {
        treeLayout = layout
    }
}
}

// MARK: - Supporting Types

fileprivate struct TreeLayout {
let nodes: [NativeTreeNode]
let spouseConnections: [Connection]
let parentChildConnections: [Connection]
let totalWidth: CGFloat
let totalHeight: CGFloat
}

fileprivate struct NativeTreeNode: Identifiable {
let id: UUID
let person: PersonRecordDisplay
let x: CGFloat
let y: CGFloat
}

fileprivate struct Connection {
let from: CGPoint
let to: CGPoint
}

fileprivate struct PersonNodeView: View {
let person: PersonRecordDisplay

var body: some View {
    HStack(spacing: 8) {
        Circle()
            .fill(Color.blue.opacity(0.15))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.blue)
            )
        
        VStack(alignment: .leading, spacing: 2) {
            Text(person.full_name)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
            
            Text("Born \(person.birth_year)")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
    .padding(8)
    .background(
        RoundedRectangle(cornerRadius: 8)
            .fill(.white)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    )
}
}

// MARK: - Preview

#Preview {
NewTreeTabView()
}
