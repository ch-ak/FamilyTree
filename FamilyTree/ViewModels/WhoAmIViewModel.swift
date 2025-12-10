import Foundation
import Combine

@MainActor
final class WhoAmIViewModel: ObservableObject {
    @Published var searchName = ""
    @Published var searchYear = ""
    @Published var foundPerson: PersonInfo?
    @Published var errorMessage: String?
    @Published var isSearching = false
    @Published var hasSearched = false
    
    private let repository: FamilyRepositoryProtocol
    
    var canSearch: Bool {
        !searchName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !searchYear.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(repository: FamilyRepositoryProtocol? = nil) {
        if let repository = repository {
            self.repository = repository
        } else {
            self.repository = DataSourceManager.shared.getCurrentRepository()
        }
    }
    
    func searchPerson() async {
        let trimmedName = searchName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedYear = searchYear.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty, !trimmedYear.isEmpty else {
            errorMessage = "Please enter both name and birth year"
            return
        }
        
        guard let year = Int(trimmedYear), year > 1700, year <= 2100 else {
            errorMessage = "Please enter a valid year between 1700 and 2100"
            return
        }
        
        isSearching = true
        hasSearched = true
        errorMessage = nil
        foundPerson = nil
        
        do {
            // Find the person
            guard let person = try await repository.findPerson(fullName: trimmedName, birthYear: year) else {
                isSearching = false
                foundPerson = nil
                return
            }
            
            // Fetch all relationships
            let parents = try await fetchRelatedPeople(personId: person.id, type: .parent)
            let siblings = try await fetchRelatedPeople(personId: person.id, type: .sibling)
            let spouses = try await fetchRelatedPeople(personId: person.id, type: .spouse)
            let children = try await fetchChildren(personId: person.id)
            
            // Build PersonInfo
            foundPerson = PersonInfo(
                id: person.id,
                fullName: person.fullName,
                birthYear: person.birthYear,
                parents: parents,
                siblings: siblings,
                spouses: spouses,
                children: children
            )
            
            isSearching = false
            
        } catch {
            isSearching = false
            errorMessage = "Error searching: \(error.localizedDescription)"
            print("❌ Search error: \(error)")
        }
    }
    
    private func fetchRelatedPeople(personId: UUID, type: RelationshipType) async throws -> [RelatedPerson] {
        let people = try await repository.fetchRelatedPeople(sourceId: personId, relationshipType: type)
        return people.map { person in
            RelatedPerson(
                id: person.id,
                fullName: person.fullName,
                birthYear: person.birthYear
            )
        }
    }
    
    private func fetchChildren(personId: UUID) async throws -> [RelatedPerson] {
        // Children are stored as PARENT relationships where the person is the related_person
        // We need to fetch people who have this person as their parent
        
        // For MockFamilyRepository
        if let mockRepo = repository as? MockFamilyRepository {
            let allRelationships = try await mockRepo.fetchAllRelationships()
            let childIds = allRelationships
                .filter { $0.relatedPersonId == personId && $0.type == .parent }
                .map { $0.personId }
            
            let allPeople = try await mockRepo.fetchAllPeople()
            let children = allPeople.filter { childIds.contains($0.id) }
            
            return children.map { person in
                RelatedPerson(
                    id: person.id,
                    fullName: person.fullName,
                    birthYear: person.birthYear
                )
            }
        }
        
        // For SupabaseFamilyRepository, we would query differently
        // For now, return empty array for Supabase
        return []
    }
}
