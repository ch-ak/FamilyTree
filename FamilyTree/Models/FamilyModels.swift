import Foundation

// MARK: - Domain Models

struct Person: Identifiable, Codable {
    let id: UUID
    let fullName: String
    let birthYear: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case birthYear = "birth_year"
    }
}

struct Relationship: Identifiable, Codable {
    let id: UUID
    let personId: UUID
    let relatedPersonId: UUID
    let type: RelationshipType
    
    enum CodingKeys: String, CodingKey {
        case id
        case personId = "person_id"
        case relatedPersonId = "related_person_id"
        case type
    }
}

enum RelationshipType: String, Codable {
    case parent = "PARENT"
    case child = "CHILD"
    case sibling = "SIBLING"
    case spouse = "SPOUSE"
}

// MARK: - Display Models (for views)

/// Display model for person data from database
struct PersonRecordDisplay: Identifiable, Decodable {
    let id: UUID
    let full_name: String
    let birth_year: Int
}

// MARK: - View Models

struct ChatMessage: Identifiable {
    enum Role {
        case system
        case user
    }
    
    let id = UUID()
    let role: Role
    let text: String
}

enum WizardStep {
    case enterSelf
    case confirmMother
    case enterMother
    case confirmFather
    case enterFather
    case confirmOtherSiblings
    case enterSpouse
    case enterSiblings
    case enterChildren
    case done
}

enum WizardError: Error, LocalizedError {
    case missingSelfPerson
    case invalidInput
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingSelfPerson:
            return "Self person ID is missing"
        case .invalidInput:
            return "Invalid input provided"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}
