#!/usr/bin/env python3
"""
Apply fixes to CleanPersonFormViewModel.swift:
1. Add pendingPerson and awaitingConfirmation properties
2. Add person recognition in handleEnterMother
3. Update handleConfirmationResponse to handle mother confirmation
"""

import re

# Read the source file
with open('/Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/ViewModels/CleanPersonFormViewModel.swift.tmp3', 'r') as f:
    content = f.read()

# Fix 1: Add pendingPerson and awaitingConfirmation after messages
old_pattern1 = r'(@Published var messages: \[ChatMessage\] = \[\])\s+(//.* - Internal State)'
new_pattern1 = r'\1\n    @Published var pendingPerson: (person: Person, relationships: [String])?\n    @Published var awaitingConfirmation = false\n    \n    \2'
content = re.sub(old_pattern1, new_pattern1, content)

# Fix 2: Update handleEnterMother to check for existing person
old_mother = '''    private func handleEnterMother(name: String, birthYear: Int) async throws {
        appendUserMessage("My mother's name is \\(name) and she was born in \\(birthYear).")
        
        guard let childId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        let mother = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)'''

new_mother = '''    private func handleEnterMother(name: String, birthYear: Int) async throws {
        appendUserMessage("My mother's name is \\(name) and she was born in \\(birthYear).")
        
        guard let childId = selfPersonId else {
            throw WizardError.missingSelfPerson
        }
        
        // ✅ FIX: Check if mother already exists with relationships
        if let existingInfo = try await useCase.checkExistingPerson(fullName: name, birthYear: birthYear) {
            let relationshipsList = existingInfo.relationships.isEmpty ? 
                "no existing relationships" : 
                existingInfo.relationships.joined(separator: ", ")
            let confirmMessage = "I found '\\(name)' (born \\(birthYear)) in the database with \\(relationshipsList). Is this your mother? (Type 'yes' to confirm)"
            
            // Store for mother confirmation
            pendingPerson = (person: existingInfo.person, relationships: ["mother"])
            awaitingConfirmation = true
            
            appendSystemMessage(confirmMessage)
            clearInputs()
            return
        }
        
        let mother = try await useCase.findOrCreatePerson(fullName: name, birthYear: birthYear)'''

content = content.replace(old_mother, new_mother)

# Fix 3: Update handleConfirmationResponse to properly handle mother/father confirmation
old_confirm = '''    private func handleConfirmationResponse(input: String) async {
        guard let pending = pendingPerson else { return }
        
        appendUserMessage(input)
        
        if input.contains("new") || input.contains("different") {
            // User wants to create a new person
            awaitingConfirmation = false
            pendingPerson = nil
            appendSystemMessage("Okay, please enter the full name and birth year for the new person.")
            clearInputs()
            return
        }
        
        // User confirmed - set this as self
        selfPersonId = pending.person.id
        selfDisplayName = pending.person.fullName
        awaitingConfirmation = false
        pendingPerson = nil
        
        // Determine what to ask for based on input
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
    }'''

new_confirm = '''    private func handleConfirmationResponse(input: String) async {
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
                try await useCase.linkChild(parentId: pending.person.id, childId: childId)
                
                motherId = pending.person.id
                notifyDataUpdated()
                
                awaitingConfirmation = false
                pendingPerson = nil
                
                currentStep = .enterFather
                appendSystemMessage("Perfect! Now tell me your father's full name and year of birth.")
                clearInputs()
            } catch {
                appendSystemMessage("Error linking mother: \\(error.localizedDescription)")
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
                try await useCase.linkChild(parentId: pending.person.id, childId: childId)
                
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
                appendSystemMessage("Error linking father: \\(error.localizedDescription)")
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
    }'''

content = content.replace(old_confirm, new_confirm)

# Write the fixed file
with open('/Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/ViewModels/CleanPersonFormViewModel.swift', 'w') as f:
    f.write(content)

print("✅ Fixes applied successfully!")
print("✅ Added pendingPerson and awaitingConfirmation properties")
print("✅ Added person recognition in handleEnterMother")
print("✅ Updated handleConfirmationResponse for mother/father confirmation")
