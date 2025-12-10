import Foundation

// MARK: - Use Cases (Business Logic)

protocol FamilyWizardUseCaseProtocol {
    func findOrCreatePerson(fullName: String, birthYear: Int) async throws -> Person
    func linkParent(childId: UUID, parentId: UUID) async throws
    func linkSpouse(personId: UUID, spouseId: UUID) async throws
    func linkSibling(personId: UUID, siblingId: UUID) async throws
    func linkChild(parentId: UUID, childId: UUID) async throws
}

final class FamilyWizardUseCase: FamilyWizardUseCaseProtocol {
    private let repository: FamilyRepositoryProtocol
    
    init(repository: FamilyRepositoryProtocol = SupabaseFamilyRepository()) {
        self.repository = repository
    }
    
    func findOrCreatePerson(fullName: String, birthYear: Int) async throws -> Person {
        print("✅ Checking if person exists: \(fullName), \(birthYear)")
        
        if let existing = try await repository.findPerson(fullName: fullName, birthYear: birthYear) {
            print("✅ Found existing person: \(existing.id)")
            return existing
        }
        
        print("✅ Creating new person: \(fullName)")
        let person = try await repository.createPerson(fullName: fullName, birthYear: birthYear)
        print("✅ Created person with ID: \(person.id)")
        return person
    }
    
    func checkExistingPerson(fullName: String, birthYear: Int) async throws -> (person: Person, relationships: [String])? {
        guard let person = try await repository.findPerson(fullName: fullName, birthYear: birthYear) else {
            return nil
        }
        
        // Get all relationships for this person
        let allRelationships = try await repository.fetchAllRelationships()
        let personRelationships = allRelationships.filter { 
            $0.personId == person.id || $0.relatedPersonId == person.id 
        }
        
        var relationshipDescriptions: [String] = []
        
        // Count relationships by type
        let parents = personRelationships.filter { $0.personId == person.id && $0.type == .parent }.count
        let children = personRelationships.filter { $0.relatedPersonId == person.id && $0.type == .parent }.count
        let spouses = personRelationships.filter { $0.type == .spouse && $0.personId == person.id }.count
        let siblings = personRelationships.filter { $0.type == .sibling && $0.personId == person.id }.count
        
        if parents > 0 {
            relationshipDescriptions.append("\(parents) parent(s)")
        }
        if children > 0 {
            relationshipDescriptions.append("\(children) child(ren)")
        }
        if spouses > 0 {
            relationshipDescriptions.append("\(spouses) spouse(s)")
        }
        if siblings > 0 {
            relationshipDescriptions.append("\(siblings) sibling(s)")
        }
        
        return (person, relationshipDescriptions)
    }
    
    func linkParent(childId: UUID, parentId: UUID) async throws {
        print("✅ Linking parent relationship: child=\(childId), parent=\(parentId)")
        try await repository.createRelationship(
            personId: childId,
            relatedPersonId: parentId,
            type: .parent
        )
        print("✅ Parent linked successfully")
    }
    
    func linkSpouse(personId: UUID, spouseId: UUID) async throws {
        print("✅ Linking spouse relationship: person=\(personId), spouse=\(spouseId)")
        
        // Bidirectional relationship
        try await repository.createRelationship(
            personId: personId,
            relatedPersonId: spouseId,
            type: .spouse
        )
        try await repository.createRelationship(
            personId: spouseId,
            relatedPersonId: personId,
            type: .spouse
        )
        
        print("✅ Spouse linked successfully")
    }
    
    func linkSibling(personId: UUID, siblingId: UUID) async throws {
        print("✅ Linking sibling relationship: person=\(personId), sibling=\(siblingId)")
        
        // Bidirectional relationship - both are siblings of each other
        try await repository.createRelationship(
            personId: personId,
            relatedPersonId: siblingId,
            type: .sibling
        )
        try await repository.createRelationship(
            personId: siblingId,
            relatedPersonId: personId,
            type: .sibling
        )
        
        print("✅ Sibling linked successfully (bidirectional)")
    }
    
    func linkChild(parentId: UUID, childId: UUID) async throws {
        print("✅ Linking child relationship: parent=\(parentId), child=\(childId)")
        try await repository.createRelationship(
            personId: childId,
            relatedPersonId: parentId,
            type: .parent
        )
        print("✅ Child linked successfully")
    }
}
