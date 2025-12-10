import Foundation
import Supabase

// MARK: - Repository Protocol (for testing)

protocol FamilyRepositoryProtocol {
    func findPerson(fullName: String, birthYear: Int) async throws -> Person?
    func createPerson(fullName: String, birthYear: Int) async throws -> Person
    func createRelationship(personId: UUID, relatedPersonId: UUID, type: RelationshipType) async throws
    func fetchRelatedPeople(sourceId: UUID, relationshipType: RelationshipType) async throws -> [Person]
}

// MARK: - Supabase Repository Implementation

final class SupabaseFamilyRepository: FamilyRepositoryProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    func findPerson(fullName: String, birthYear: Int) async throws -> Person? {
        do {
            let response: [Person] = try await client
                .from("person")
                .select("id,full_name,birth_year")
                .eq("full_name", value: fullName)
                .eq("birth_year", value: birthYear)
                .limit(1)
                .execute()
                .value
            return response.first
        } catch {
            print("❌ findPerson error for \(fullName): \(error)")
            return nil // Graceful fallback
        }
    }
    
    func createPerson(fullName: String, birthYear: Int) async throws -> Person {
        struct PersonInsert: Encodable {
            let full_name: String
            let birth_year: Int
        }
        
        let insert = PersonInsert(full_name: fullName, birth_year: birthYear)
        
        let response: [Person] = try await client
            .from("person")
            .insert(insert)
            .select("id,full_name,birth_year")
            .execute()
            .value
        
        guard let person = response.first else {
            throw WizardError.databaseError("Failed to create person")
        }
        
        return person
    }
    
    func createRelationship(personId: UUID, relatedPersonId: UUID, type: RelationshipType) async throws {
        struct RelationshipInsert: Encodable {
            let person_id: UUID
            let related_person_id: UUID
            let type: String
        }
        
        let insert = RelationshipInsert(
            person_id: personId,
            related_person_id: relatedPersonId,
            type: type.rawValue
        )
        
        _ = try await client
            .from("relationship")
            .insert(insert)
            .execute()
    }
    
    func fetchRelatedPeople(sourceId: UUID, relationshipType: RelationshipType) async throws -> [Person] {
        do {
            struct RelationshipRow: Decodable {
                let related_person: Person?
            }
            
            let rows: [RelationshipRow] = try await client
                .from("relationship")
                .select("related_person:related_person_id(id,full_name,birth_year)")
                .eq("person_id", value: sourceId)
                .eq("type", value: relationshipType.rawValue)
                .execute()
                .value
            
            return rows.compactMap { $0.related_person }
        } catch {
            print("❌ fetchRelatedPeople error: \(error)")
            return []
        }
    }
}
