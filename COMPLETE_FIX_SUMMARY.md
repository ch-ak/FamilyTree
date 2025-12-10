import Foundation
import Combine

// MARK: - Clean Person Form ViewModel

/// ViewModel responsible for managing the family wizard flow
/// Follows MVVM pattern with clear separation of concerns
@MainActor
final class CleanPersonFormViewModel: ObservableObject {
    
    // MARK: - Published Properties (View State)
    
    @Published var fullName = ""
    @Published var birthYear = ""
    @Published var statusMessage: String?
    @Published var isSubmitting = false
    @Published var currentStep: WizardStep = .enterSelf
    @Published var messages: [ChatMessage] = []
    @Published var pendingPerson: (person: Person, relationships: [String])?
    @Published var awaitingConfirmation = false
    
    // MARK: - Internal State
    
    @Published var selfPersonId: UUID?
    @Published var selfDisplayName: String?
    
    private var motherId: UUID?
    private var fatherId: UUID?
    private var spouseId: UUID?
    private var siblingIds: [UUID] = []
    private var childrenIds: [UUID] = []
    
    // MARK: - Dependencies
    
    private let useCase: FamilyWizardUseCaseProtocol
    private let familyLastName: String
    
    // MARK: - Initialization
    
    init(useCase: FamilyWizardUseCaseProtocol? = nil,
         familyLastName: String = "Kocherlakota") {
        self.familyLastName = familyLastName
        
        if let useCase = useCase {
            self.useCase = useCase
        } else {
            self.useCase = DataSourceManager.shared.getCurrentUseCase()
        }
        
        appendSystemMessage("Hi! Let's start with your details, then capture your mother, father, spouse, siblings, and kids. What is your full name and year of birth?")
    }
    
    // MARK: - Public Methods
    
    func submit() {
        Task { await handleSubmit() }
    }
    
    func restartWizard() {
        resetState()
        currentStep = .enterSelf
        messages.removeAll()
        appendSystemMessage("Great! Let's add another family member. What is their full name and year of birth?")
    }
    
    // MARK: - Message Management
    
    func appendSystemMessage(_ text: String) {
        messages.append(ChatMessage(role: .system, text: text))
    }
    
    func appendUserMessage(_ text: String) {
        messages.append(ChatMessage(role: .user, text: text))
    }
    
    // MARK: - Private Methods - Submit Flow
    
    private func handleSubmit() async {
        guard currentStep != .done else {
            statusMessage = "Wizard already completed."
            return
        }
        
        statusMessage = nil
        
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedYear = birthYear.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle confirmation state
        if awaitingConfirmation {
            await handleConfirmationResponse(input: trimmedName.lowercased())
            return
        }
        
        // Handle optional steps with blank inputs
        if isOptionalStep(currentStep) && trimmedName.isEmpty && trimmedYear.isEmpty {
            advancePastOptionalStep()
            return
        }
        
        guard validateInputs() else { return }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        guard let yearValue = Int(trimmedYear) else {
            statusMessage = "Invalid year format"
            autoCloseError()
            return
        }

        do {
            try await processStep(name: trimmedName, birthYear: yearValue)
        } catch {
            print("❌ Error in step \(currentStep): \(error)")
            statusMessage = "Error: \(error.localizedDescription)"
            autoCloseError()
        }
    }
    
    // MARK: - Confirmation Handler
    
    private func handleConfirmationResponse(input: String) async {
        guard let pending = pendingPerson else { return }
        
        appendUserMessage(input)
        
        if input.contains("no") || input.contains("new") || input.contains("different") {
            // User wants to create a new person
            awaitingConfirmation = false
            pendingPerson = nil
            appendSystemMessage("Okay, please enter the full name and birth year again for the new person.")
            clearInputs()
            return
        }
        
        // Check if this is a parent confirmation (mother/father)
        if pending.relationships.contains("mother") && input.contains("yes") {
            // User confirmed mother
            guard let childId = selfPersonId else {
                awaitingConfirmation = false
                pendingPerson = nil
                return
            }
            
            // Link the confirmed mother
            do {
                try await useCase.linkParent(childId: childId, parentId: pending.person.id)
                
                motherId = pending.person.id
                notifyDataUpdated()
                
                awaitingConfirmation = false
                pendingPerson = nil
                
                currentStep = .enterFather
                appendSystemMessage("Perfect! Now tell me your father's full name and year of birth.")
                clearInputs()
            } catch {
                appendSystemMessage("Error linking mother: \(error.localizedDescription)")
                awaitingConfirmation = false
                pendingPerson = nil
                clearInputs()
            }
            return
        }
        
        if pending.relationships.contains("father") && input.contains("yes") {
            // User confirmed father
            guard let childId = selfPersonId else {
                awaitingConfirmation = false
                pendingPerson = nil
                return
            }
            
            // Link the confirmed father
            do {
                try await useCase.linkParent(childId: childId, parentId: pending.person.id)
                
                fatherId = pending.person.id
                
                // Link parents as spouses if mother exists
                if let motherId = motherId {
                    try await useCase.linkSpouse(personId: motherId, spouseId: pending.person.id)
                    print("✅ Linked mother and father as spouses")
                }
                
                notifyDataUpdated()
                
                awaitingConfirmation = false
                pendingPerson = nil
                
                // Check if person already has a spouse before asking
                let hasExistingSpouse = try await checkForExistingSpouse()
                if hasExistingSpouse {
                    print("✅ Person already has a spouse, skipping to siblings")
                    currentStep = .enterSiblings
                    appendSystemMessage("Great! I see you're already married. Do you have any siblings? Enter one sibling's full name and birth year, or leave both blank to skip.")
                } else {
                    currentStep = .enterSpouse
                    appendSystemMessage("Great! Are you married? Enter your spouse's full name and birth year, or leave both blank to skip.")
                }
                
                clearInputs()
            } catch {
                appendSystemMessage("Error linking father: \(error.localizedDescription)")
                awaitingConfirmation = false
                pendingPerson = nil
                clearInputs()
            }
            return
        }
        
        // Original self-confirmation logic
        selfPersonId = pending.person.id
        selfDisplayName = pending.person.fullName
        awaitingConfirmation = false
        pendingPerson = nil
        
        // Determine what to ask for based on relationships
        if input.contains("mother") {
            currentStep = .enterMother
            appendSystemMessage("Great! Tell me your mother's full name and year of birth.")
        } else if input.contains("father") {
            currentStep = .enterFather
            appendSystemMessage("Great! Tell me your father's full name and year of birth.")
        } else if input.contains("spouse") {
            currentStep = .enterSpouse
            appendSystemMessage("Great! Tell me your spouse's full name and year of birth.")
        } else if input.contains("sibling") {
            currentStep = .enterSiblings
            appendSystemMessage("Great! Tell me your sibling's full name and year of birth.")
        } else if input.contains("child") {
            currentStep = .enterChildren
            appendSystemMessage("Great! Tell me your child's full name and year of birth.")
        } else {
            // Default to asking for mother
            currentStep = .enterMother
            appendSystemMessage("Okay! Let's start with your mother. What is her full name and year of birth?")
        }
        
        clearInputs()
    }
    
    // MARK: - Validation
    
    private func validateInputs() -> Bool {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedYear = birthYear.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            statusMessage = "Please enter a name"
            autoCloseError()
            return false
        }
        
        guard !trimmedYear.isEmpty else {
            statusMessage = "Please enter a birth year"
            autoCloseError()
            return false
        }
        
        guard let year = Int(trimmedYear), year > 1700, year <= 2100 else {
            statusMessage = "Please enter a valid year between 1700 and 2100"
            autoCloseError()
            return false
        }
        
        return true
    }
    
    // MARK: - Step Processing
    
    private func processStep(name: String, birthYear: Int) async throws {
        switch currentStep {
        case .enterSelf:
            try await handleEnterSelf(name: name, birthYear: birthYear)
        case .enterMother:
            try await handleEnterMother(name: name, birthYear: birthYear)
        case .enterFather:
            try await handleEnterFather(name: name, birthYear: birthYear)
        case .enterSpouse:
            try await handleEnterSpouse(name: name, birthYear: birthYear)
        case .enterSiblings:
            try await handleEnterSiblings(name: name, birthYear: birthYear)
        case .enterChildren:
            try await handleEnterChildren(name: name, birthYear: birthYear)
        case .confirmMother, .confirmFather, .confirmOtherSiblings:
            // Confirm steps not used in this simplified wizard flow
            break
        case .done:
            break
        }
    }
    
    // MARK: - Step Handlers
    
    private func handleEnterSelf(name: String, birthYear: Int) async throws {
        appendUserMessage("My name is \(name) and I was born in \(birthYear).")
        
        let person = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)
        selfPersonId = person.id
        selfDisplayName = name
        
        notifyDataUpdated()
        
        let wasExisting = person.fullName == name && person.birthYear == birthYear
        if wasExisting {
            appendSystemMessage("✅ Found you in the family tree! I'll link your family members to your existing profile. Now, tell me your mother's full name and year of birth.")
        } else {
            appendSystemMessage("Great! Now tell me your mother's full name and year of birth.")
        }
        
        currentStep = .enterMother
        clearInputs()
    }
    
    private func handleEnterMother(name: String, birthYear: Int) async throws {
        appendUserMessage("My mother's name is \(name) and she was born in \(birthYear).")
        
        guard let childId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        // ✅ FIX: Check if this person already has parents before asking
        let repository = DataSourceManager.shared.getCurrentRepository()
        let existingParents = try await repository.fetchRelatedPeople(sourceId: childId, relationshipType: .parent)
        
        if !existingParents.isEmpty {
            appendSystemMessage("I see you already have parents in the database. I'll skip the parent questions.")
            currentStep = .enterSpouse
            appendSystemMessage("Are you married? Enter your spouse's full name and birth year, or leave both blank to skip.")
            clearInputs()
            return
        }
        
        // ✅ FIX: Check if mother already exists and show relationships
        if let existingPerson = try await repository.findPerson(fullName: name, birthYear: birthYear) {
            // Person exists - fetch their relationships to show context
            let relationshipInfo = await fetchPersonRelationships(personId: existingPerson.id)
            
            let confirmMessage = "I found '\(name)' (born \(birthYear)) in the database with \(relationshipInfo). Is this your mother? (Type 'yes' to confirm or 'no' for a different person)"
            
            // Store for mother confirmation
            pendingPerson = (person: existingPerson, relationships: ["mother"])
            awaitingConfirmation = true
            
            appendSystemMessage(confirmMessage)
            clearInputs()
            return
        }
        
        // Person doesn't exist - create new
        let mother = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)
        
        // Create parent-child relationship (NOT bidirectional - child points to parent)
        try await useCase.linkParent(childId: childId, parentId: mother.id)
        
        motherId = mother.id
        notifyDataUpdated()
        
        currentStep = .enterFather
        appendSystemMessage("Perfect! Now tell me your father's full name and year of birth.")
        clearInputs()
    }
    
    private func handleEnterFather(name: String, birthYear: Int) async throws {
        appendUserMessage("My father's name is \(name) and he was born in \(birthYear).")
        
        guard let childId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        // ✅ FIX: Check if father already exists and show relationships
        if let existingPerson = try await useCase.findPerson(fullName: name, birthYear: birthYear) {
            // Person exists - fetch their relationships to show context
            let relationshipInfo = await fetchPersonRelationships(personId: existingPerson.id)
            
            let confirmMessage = "I found '\(name)' (born \(birthYear)) in the database with \(relationshipInfo). Is this your father? (Type 'yes' to confirm or 'no' for a different person)"
            
            // Store for father confirmation
            pendingPerson = (person: existingPerson, relationships: ["father"])
            awaitingConfirmation = true
            
            appendSystemMessage(confirmMessage)
            clearInputs()
            return
        }
        
        // Person doesn't exist - create new
        let father = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)
        
        // Create parent-child relationship (NOT bidirectional - child points to parent only)
        try await useCase.linkParent(childId: childId, parentId: father.id)
        
        fatherId = father.id
        
        // Link parents as spouses if mother exists
        if let motherId = motherId {
            try await useCase.linkSpouse(personId: motherId, spouseId: father.id)
            print("✅ Linked mother and father as spouses")
        }
        
        notifyDataUpdated()
        
        // Check if person already has a spouse before asking
        let hasExistingSpouse = try await checkForExistingSpouse()
        if hasExistingSpouse {
            print("✅ Person already has a spouse, skipping to siblings")
            currentStep = .enterSiblings
            appendSystemMessage("Great! I see you're already married. Do you have any siblings? Enter one sibling's full name and birth year, or leave both blank to skip.")
        } else {
            currentStep = .enterSpouse
            appendSystemMessage("Great! Are you married? Enter your spouse's full name and birth year, or leave both blank to skip.")
        }
        
        clearInputs()
    }
    
    private func handleEnterSpouse(name: String, birthYear: Int) async throws {
        appendUserMessage("My spouse's name is \(name) and they were born in \(birthYear).")
        
        guard let meId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        let spouse = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)
        try await useCase.linkSpouse(personId: meId, spouseId: spouse.id)
        
        spouseId = spouse.id
        notifyDataUpdated()
        
        currentStep = .enterSiblings
        appendSystemMessage("Perfect! Do you have any siblings? Enter one sibling's full name and birth year, or leave both blank to skip.")
        clearInputs()
    }
    
    private func handleEnterSiblings(name: String, birthYear: Int) async throws {
        appendUserMessage("My sibling's name is \(name) and they were born in \(birthYear).")
        
        guard let meId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        let sibling = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)
        
        // Create bidirectional sibling relationship
        try await useCase.linkSibling(personId: meId, siblingId: sibling.id)
        
        // Link sibling to parents if they exist (only parent link needed, not child link)
        if let motherId = motherId {
            try await useCase.linkParent(childId: sibling.id, parentId: motherId)
        }
        if let fatherId = fatherId {
            try await useCase.linkParent(childId: sibling.id, parentId: fatherId)
        }
        
        // CRITICAL FIX: Link new sibling to ALL previously added siblings
        // This ensures Karunya and Saranya are linked to each other, not just to Lavanya
        for existingSiblingId in siblingIds {
            try await useCase.linkSibling(personId: sibling.id, siblingId: existingSiblingId)
            print("✅ Linked \(sibling.fullName) as sibling to existing sibling")
        }
        
        // Add this sibling to the list for future siblings
        siblingIds.append(sibling.id)
        
        notifyDataUpdated()
        
        appendSystemMessage("Saved! Add another sibling, or leave blank to continue.")
        clearInputs()
    }
    
    private func handleEnterChildren(name: String, birthYear: Int) async throws {
        appendUserMessage("My child's name is \(name) and they were born in \(birthYear).")
        
        guard let parentId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        let child = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)
        
        // Link child to self (bidirectional)
        try await useCase.linkChild(parentId: parentId, childId: child.id)
        try await useCase.linkParent(childId: child.id, parentId: parentId)
        
        // Link child to spouse if spouse exists (bidirectional)
        if let spouseId = spouseId {
            try await useCase.linkChild(parentId: spouseId, childId: child.id)
            try await useCase.linkParent(childId: child.id, parentId: spouseId)
            print("✅ Linked child to spouse")
        }
        
        // Link child as sibling to all previously added children
        for existingChildId in childrenIds {
            try await useCase.linkSibling(personId: child.id, siblingId: existingChildId)
            print("✅ Linked \(child.fullName) as sibling to existing child")
        }
        
        childrenIds.append(child.id)
        notifyDataUpdated()
        
        appendSystemMessage("Saved! Add another child, or leave blank to finish.")
        clearInputs()
    }
    
    // MARK: - Helper Methods
    
    private func findPerson(fullName: String, birthYear: Int) async throws -> Person? {
        let repository = DataSourceManager.shared.getCurrentRepository()
        return try await repository.findPerson(fullName: fullName, birthYear: birthYear)
    }
    
    private func fetchPersonRelationships(personId: UUID) async -> String {
        do {
            let repository = DataSourceManager.shared.getCurrentRepository()
            
            // For MockFamilyRepository
            if let mockRepo = repository as? MockFamilyRepository {
                let allRelationships = try await mockRepo.fetchAllRelationships()
                _ = try await mockRepo.fetchAllPeople()
                
                // Count relationships
                var childrenCount = 0
                var spousesCount = 0
                var siblingsCount = 0
                var parentsCount = 0
                
                // Count children (people who have this person as parent)
                childrenCount = allRelationships.filter {
                    $0.relatedPersonId == personId && $0.type == .parent
                }.count
                
                // Count spouses
                spousesCount = allRelationships.filter {
                    $0.personId == personId && $0.type == .spouse
                }.count
                
                // Count siblings
                siblingsCount = allRelationships.filter {
                    $0.personId == personId && $0.type == .sibling
                }.count
                
                // Count parents
                parentsCount = allRelationships.filter {
                    $0.personId == personId && $0.type == .parent
                }.count
                
                var parts: [String] = []
                if childrenCount > 0 { parts.append("\(childrenCount) child(ren)") }
                if spousesCount > 0 { parts.append("\(spousesCount) spouse(s)") }
                if siblingsCount > 0 { parts.append("\(siblingsCount) sibling(s)") }
                if parentsCount > 0 { parts.append("\(parentsCount) parent(s)") }
                
                return parts.isEmpty ? "no existing relationships" : parts.joined(separator: ", ")
            }
            
            return "existing relationships (details not available)"
        } catch {
            return "unknown relationships"
        }
    }
    
    private func checkForExistingSpouse() async throws -> Bool {
        guard let personId = selfPersonId else {
            return false
        }
        
        let repository = DataSourceManager.shared.getCurrentRepository()
        
        // Check for existing spouse in mock data
        if let mockRepo = repository as? MockFamilyRepository {
            let relationships = try await mockRepo.fetchAllRelationships()
            return relationships.contains { rel in
                rel.personId == personId && rel.type == .spouse
            }
        }
        
        // For Supabase, we would need to query the database
        // For now, return false (spouse question will always be asked for Supabase)
        return false
    }
    
    private func notifyDataUpdated() {
        Task { @MainActor in
            NotificationCenter.default.post(
                name: NSNotification.Name("PersonAdded"),
                object: nil
            )
        }
    }
    
    private func isOptionalStep(_ step: WizardStep) -> Bool {
        switch step {
        case .enterSpouse, .enterSiblings, .enterChildren:
            return true
        default:
            return false
        }
    }
    
    private func advancePastOptionalStep() {
        switch currentStep {
        case .enterSpouse:
            currentStep = .enterSiblings
            appendSystemMessage("No problem! Do you have any siblings? Enter their name and birth year, or leave blank to skip.")
        case .enterSiblings:
            currentStep = .enterChildren
            appendSystemMessage("Now let's capture your children. Enter a child's name and birth year, or leave both blank to finish.")
        case .enterChildren:
            currentStep = .done
            appendSystemMessage("🎉 You're all set! Check the Family Tree tabs to see your family. You can run this wizard again to add more family members!")
        default:
            break
        }
        clearInputs()
    }
    
    private func clearInputs() {
        fullName = ""
        birthYear = ""
    }
    
    private func resetState() {
        fullName = ""
        birthYear = ""
        selfPersonId = nil
        selfDisplayName = nil
        motherId = nil
        fatherId = nil
        spouseId = nil
        siblingIds.removeAll()
        childrenIds.removeAll()
    }
    
    private func autoCloseError() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                statusMessage = nil
            }
        }
    }
}
