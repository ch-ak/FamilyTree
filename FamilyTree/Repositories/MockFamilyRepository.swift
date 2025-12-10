import Foundation

// MARK: - Mock Relationship

struct MockRelationship: Identifiable {
    let id: UUID
    let personId: UUID
    let relatedPersonId: UUID
    let type: RelationshipType
}

// MARK: - Mock Repository

final class MockFamilyRepository: FamilyRepositoryProtocol {
    private var people: [Person]
    private var relationships: [MockRelationship]
    private var personCache: [UUID: Person] = [:]
    
    init() {
        // Use ONLY the real Kocherlakota family data
        let mockData = RealFamilyMockDataGenerator.generateKocherlakotaFamily()
        self.people = mockData.people
        self.relationships = mockData.relationships
        
        // Build cache
        for person in people {
            personCache[person.id] = person
        }
        
        // ✅ CRITICAL FIX: Remove duplicate relationships on initialization
        self.relationships = removeDuplicateRelationships(from: self.relationships)
        
        print("🎭 MockFamilyRepository initialized with \(people.count) people and \(relationships.count) relationships")
    }
    
    // Helper to remove duplicate relationships
    private func removeDuplicateRelationships(from relationships: [MockRelationship]) -> [MockRelationship] {
        var seen = Set<String>()
        var uniqueRelationships: [MockRelationship] = []
        
        for rel in relationships {
            // Create unique key for this relationship
            let key = "\(rel.personId)-\(rel.relatedPersonId)-\(rel.type.rawValue)"
            
            if !seen.contains(key) {
                seen.insert(key)
                uniqueRelationships.append(rel)
            } else {
                print("🎭 Removed duplicate relationship: \(rel.type.rawValue)")
            }
        }
        
        print("🎭 Cleaned \(relationships.count - uniqueRelationships.count) duplicate relationships")
        return uniqueRelationships
    }
    
    func findPerson(fullName: String, birthYear: Int) async throws -> Person? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Exact match on name and year
        return people.first { $0.fullName == fullName && $0.birthYear == birthYear }
    }
    
    func createPerson(fullName: String, birthYear: Int) async throws -> Person {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let person = Person(
            id: UUID(),
            fullName: fullName,
            birthYear: birthYear
        )
        people.append(person)
        personCache[person.id] = person
        
        print("🎭 Mock: Created person \(fullName)")
        return person
    }
    
    func createRelationship(personId: UUID, relatedPersonId: UUID, type: RelationshipType) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // ✅ FIX: Check for duplicate relationship before creating
        let isDuplicate = relationships.contains { rel in
            rel.personId == personId &&
            rel.relatedPersonId == relatedPersonId &&
            rel.type == type
        }
        
        if isDuplicate {
            print("🎭 Mock: Relationship already exists, skipping duplicate")
            return
        }
        
        let relationship = MockRelationship(
            id: UUID(),
            personId: personId,
            relatedPersonId: relatedPersonId,
            type: type
        )
        relationships.append(relationship)
        print("🎭 Mock: Created \(type.rawValue) relationship")
    }
    
    func fetchRelatedPeople(sourceId: UUID, relationshipType: RelationshipType) async throws -> [Person] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // ✅ FIX: Deduplicate related IDs to prevent showing same person twice
        let relatedIds = Set(relationships
            .filter { $0.personId == sourceId && $0.type == relationshipType }
            .map { $0.relatedPersonId })
        
        return relatedIds.compactMap { personCache[$0] }
    }
    
    // Helper methods for full tree view
    func fetchAllPeople() async throws -> [Person] {
        try await Task.sleep(nanoseconds: 100_000_000)
        return people
    }
    
    func fetchAllRelationships() async throws -> [MockRelationship] {
        try await Task.sleep(nanoseconds: 100_000_000)
        return relationships
    }
}
