import Foundation

// MARK: - Mock Data Generator for Testing

final class MockFamilyDataGenerator {
    
    // MARK: - Generate Mock Data
    
    static func generate200PeopleFamily() -> (people: [Person], relationships: [MockRelationship]) {
        var people: [Person] = []
        var relationships: [MockRelationship] = []
        
        // Generate 8 generations (200+ people)
        // Generation 1: 1720-1750 (ancestors)
        // Generation 2: 1750-1780
        // Generation 3: 1780-1810
        // Generation 4: 1810-1840
        // Generation 5: 1840-1870
        // Generation 6: 1870-1900
        // Generation 7: 1900-1930
        // Generation 8: 1930-1960
        // Generation 9: 1960-1990
        // Generation 10: 1990-2020 (youngest)
        
        let lastNames = ["Kocherlakota", "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez"]
        let maleFirstNames = ["James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Thomas", "Charles", "Rama", "Krishna", "Venkata", "Srinivas", "Murthy", "Ravi", "Suresh", "Kumar", "Prasad", "Mohan"]
        let femaleFirstNames = ["Mary", "Patricia", "Jennifer", "Linda", "Barbara", "Elizabeth", "Susan", "Jessica", "Sarah", "Karen", "Lakshmi", "Sita", "Radha", "Kamala", "Savitri", "Parvati", "Durga", "Uma", "Ganga", "Saraswati"]
        
        // Generation 1: Root ancestors (1720-1750)
        let gen1 = generateGeneration(
            count: 4,
            startYear: 1720,
            endYear: 1750,
            maleNames: maleFirstNames,
            femaleNames: femaleFirstNames,
            lastNames: lastNames,
            people: &people
        )
        
        // Create couples and their children for each generation
        var currentGen = gen1
        var allGenerations: [[Person]] = [gen1]
        
        for genIndex in 2...10 {
            let baseYear = 1720 + (genIndex - 1) * 30
            let childrenPerCouple = genIndex < 8 ? 3 : 2 // Fewer children in later generations
            
            var nextGen: [Person] = []
            
            // Create couples from current generation
            for i in stride(from: 0, to: currentGen.count - 1, by: 2) {
                let parent1 = currentGen[i]
                let parent2 = currentGen[i + 1]
                
                // Create spouse relationship
                relationships.append(MockRelationship(
                    id: UUID(),
                    personId: parent1.id,
                    relatedPersonId: parent2.id,
                    type: .spouse
                ))
                relationships.append(MockRelationship(
                    id: UUID(),
                    personId: parent2.id,
                    relatedPersonId: parent1.id,
                    type: .spouse
                ))
                
                // Generate children
                for childIndex in 0..<childrenPerCouple {
                    let isMale = Bool.random()
                    let firstName = isMale ? maleFirstNames.randomElement()! : femaleFirstNames.randomElement()!
                    let lastName = parent1.fullName.components(separatedBy: " ").last ?? "Kocherlakota"
                    let birthYear = baseYear + Int.random(in: 0...25)
                    
                    let child = Person(
                        id: UUID(),
                        fullName: "\(firstName) \(lastName)",
                        birthYear: birthYear
                    )
                    people.append(child)
                    nextGen.append(child)
                    
                    // Link child to parents
                    relationships.append(MockRelationship(
                        id: UUID(),
                        personId: child.id,
                        relatedPersonId: parent1.id,
                        type: .parent
                    ))
                    relationships.append(MockRelationship(
                        id: UUID(),
                        personId: child.id,
                        relatedPersonId: parent2.id,
                        type: .parent
                    ))
                    
                    // Link siblings
                    for sibling in nextGen.dropLast() {
                        if relationships.contains(where: { 
                            $0.personId == child.id && $0.relatedPersonId == sibling.id && $0.type == .sibling 
                        }) {
                            continue
                        }
                        relationships.append(MockRelationship(
                            id: UUID(),
                            personId: child.id,
                            relatedPersonId: sibling.id,
                            type: .sibling
                        ))
                        relationships.append(MockRelationship(
                            id: UUID(),
                            personId: sibling.id,
                            relatedPersonId: child.id,
                            type: .sibling
                        ))
                    }
                }
            }
            
            allGenerations.append(nextGen)
            currentGen = nextGen
        }
        
        print("✅ Generated \(people.count) people across \(allGenerations.count) generations")
        print("✅ Generated \(relationships.count) relationships")
        
        return (people, relationships)
    }
    
    private static func generateGeneration(
        count: Int,
        startYear: Int,
        endYear: Int,
        maleNames: [String],
        femaleNames: [String],
        lastNames: [String],
        people: inout [Person]
    ) -> [Person] {
        var generation: [Person] = []
        
        for i in 0..<count {
            let isMale = i % 2 == 0
            let firstName = isMale ? maleNames.randomElement()! : femaleNames.randomElement()!
            let lastName = lastNames.randomElement()!
            let birthYear = Int.random(in: startYear...endYear)
            
            let person = Person(
                id: UUID(),
                fullName: "\(firstName) \(lastName)",
                birthYear: birthYear
            )
            people.append(person)
            generation.append(person)
        }
        
        return generation
    }
}

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
        // Use real Kocherlakota family data instead of generated data
        let mockData = RealFamilyMockDataGenerator.generateKocherlakotaFamily()
        self.people = mockData.people
        self.relationships = mockData.relationships
        
        // Build cache
        for person in people {
            personCache[person.id] = person
        }
        
        print("🎭 MockFamilyRepository initialized with \(people.count) people")
    }
    
    func findPerson(fullName: String, birthYear: Int) async throws -> Person? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        return people.first { person in
            person.fullName.lowercased() == fullName.lowercased() &&
            person.birthYear == birthYear
        }
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
        
        let relatedIds = relationships
            .filter { $0.personId == sourceId && $0.type == relationshipType }
            .map { $0.relatedPersonId }
        
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
