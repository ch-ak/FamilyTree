# Architecture Refactoring - Clean Architecture + MVVM

## 📊 Overview

Your app now follows **Clean Architecture** principles with a clear separation of concerns:

```
┌─────────────────────────────────────────────────┐
│                    Views                        │  ← SwiftUI Views (UI only)
│              (ChatWizardView)                   │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                ViewModels                       │  ← Presentation Logic
│           (PersonFormViewModel)                 │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                Use Cases                        │  ← Business Logic
│          (FamilyWizardUseCase)                  │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│               Repositories                      │  ← Data Access Layer
│         (SupabaseFamilyRepository)              │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                 Models                          │  ← Domain Entities
│         (Person, Relationship)                  │
└─────────────────────────────────────────────────┘
```

---

## 🏗️ New Architecture

### 1. **Models Layer** (Domain Entities)
**File:** `Models/FamilyModels.swift`

```swift
✅ Person - Domain entity (not coupled to database)
✅ Relationship - Domain entity
✅ RelationshipType - Enum for type safety
✅ ChatMessage - View model for UI
✅ WizardStep - State management
✅ WizardError - Error handling
```

**Benefits:**
- Pure Swift (no Supabase dependency)
- Reusable across different data sources
- Easy to test

---

### 2. **Repository Layer** (Data Access)
**File:** `Repositories/FamilyRepository.swift`

```swift
protocol FamilyRepositoryProtocol {
    func findPerson(...) async throws -> Person?
    func createPerson(...) async throws -> Person
    func createRelationship(...) async throws
    func fetchRelatedPeople(...) async throws -> [Person]
}

class SupabaseFamilyRepository: FamilyRepositoryProtocol {
    // Handles ALL database operations
    // Can be swapped with MockRepository for testing
}
```

**Benefits:**
- ✅ Single responsibility (data access only)
- ✅ Protocol-based (testable with mocks)
- ✅ Hides Supabase implementation details
- ✅ Easy to switch databases (Firebase, Core Data, etc.)

---

### 3. **Use Cases Layer** (Business Logic)
**File:** `UseCases/FamilyWizardUseCase.swift`

```swift
protocol FamilyWizardUseCaseProtocol {
    func findOrCreatePerson(...) async throws -> Person
    func linkParent(...) async throws
    func linkSpouse(...) async throws
    func linkSibling(...) async throws
    func linkChild(...) async throws
}

class FamilyWizardUseCase: FamilyWizardUseCaseProtocol {
    // Contains business rules:
    // - Find or create logic
    // - Bidirectional spouse linking
    // - Logging & error handling
}
```

**Benefits:**
- ✅ Reusable business logic
- ✅ Independent of UI
- ✅ Easy to test
- ✅ Single responsibility

---

### 4. **ViewModel Layer** (Presentation Logic)
**File:** `ViewModels/PersonFormViewModel.swift`

**Reduced from 500+ lines to ~250 lines!**

```swift
@MainActor
final class PersonFormViewModel: ObservableObject {
    // ONLY handles:
    // ✅ User input validation
    // ✅ UI state management
    // ✅ Step navigation
    // ✅ Message display
    
    // Delegates business logic to UseCase
    private let useCase: FamilyWizardUseCaseProtocol
    
    init(useCase: FamilyWizardUseCaseProtocol = FamilyWizardUseCase()) {
        self.useCase = useCase
    }
}
```

**Benefits:**
- ✅ Clean & focused
- ✅ Easy to understand
- ✅ Testable (mock use case)
- ✅ No database code

---

### 5. **View Layer** (UI Only)
**File:** `ChatWizardView.swift` *(Already clean!)*

```swift
struct ChatWizardView: View {
    @ObservedObject var viewModel: PersonFormViewModel
    
    var body: some View {
        // ONLY UI code
        // No business logic
    }
}
```

---

## 🎯 Key Improvements

### **Before (Monolithic)**
```swift
PersonFormViewModel (500+ lines) {
    ❌ Database queries
    ❌ Business logic
    ❌ UI state
    ❌ Validation
    ❌ Error handling
    ❌ Relationship linking
    → Everything in one file!
}
```

### **After (Clean Architecture)**
```swift
Models (50 lines)
    ✅ Pure domain entities

Repository (100 lines)
    ✅ Database operations only

UseCase (100 lines)
    ✅ Business logic only

ViewModel (250 lines)
    ✅ Presentation logic only

View (200 lines)
    ✅ UI only
```

---

## 🧪 Testability

### **Before**
```swift
❌ Can't test ViewModel without Supabase
❌ Can't test business logic separately
❌ Tightly coupled code
```

### **After**
```swift
✅ Test UseCase with MockRepository
✅ Test ViewModel with MockUseCase
✅ Test each layer independently
✅ Protocol-based dependency injection
```

**Example Test:**
```swift
class PersonFormViewModelTests: XCTestCase {
    func testEnterSelf() async {
        // Arrange
        let mockUseCase = MockFamilyWizardUseCase()
        let viewModel = PersonFormViewModel(useCase: mockUseCase)
        
        // Act
        viewModel.fullName = "Test User"
        viewModel.birthYear = "1990"
        await viewModel.submit()
        
        // Assert
        XCTAssertEqual(viewModel.currentStep, .enterMother)
        XCTAssertTrue(mockUseCase.findOrCreatePersonCalled)
    }
}
```

---

## 📦 Project Structure

```
FamilyTree/
├── Models/
│   └── FamilyModels.swift          ← Domain entities
├── Repositories/
│   └── FamilyRepository.swift      ← Data access layer
├── UseCases/
│   └── FamilyWizardUseCase.swift   ← Business logic
├── ViewModels/
│   └── PersonFormViewModel.swift   ← Presentation logic
├── Views/
│   ├── ChatWizardView.swift        ← UI
│   ├── FamilyTreeTabView.swift
│   └── FullFamilyTreeTabView.swift
└── Managers/
    └── SupabaseManager.swift       ← Configuration
```

---

## ✅ SOLID Principles Applied

### **S - Single Responsibility**
- ✅ Repository: Data access only
- ✅ UseCase: Business logic only
- ✅ ViewModel: Presentation only
- ✅ View: UI only

### **O - Open/Closed**
- ✅ Add new relationship types without changing existing code
- ✅ Extend functionality via protocols

### **L - Liskov Substitution**
- ✅ Can swap SupabaseFamilyRepository with any FamilyRepositoryProtocol implementation

### **I - Interface Segregation**
- ✅ Small, focused protocols
- ✅ No fat interfaces

### **D - Dependency Inversion**
- ✅ ViewModel depends on UseCase protocol (not implementation)
- ✅ UseCase depends on Repository protocol (not implementation)
- ✅ Easy to inject mocks for testing

---

## 🚀 Migration Path

**Option 1: Gradual Migration** (Recommended)
1. Keep existing `PersonFormViewModel.swift` as backup
2. Add new files to project
3. Update `ChatWizardView` to use new ViewModel
4. Test thoroughly
5. Delete old ViewModel

**Option 2: Complete Replacement**
1. Delete old `PersonFormViewModel.swift`
2. Add all new files
3. Update imports
4. Test

---

## 🎉 Benefits Summary

### **Code Quality**
✅ **Clean** - Each file has one responsibility
✅ **Maintainable** - Easy to find and fix bugs
✅ **Readable** - Clear separation of concerns
✅ **Testable** - Protocol-based design

### **Developer Experience**
✅ **Faster development** - Know exactly where to add features
✅ **Easier debugging** - Isolated layers
✅ **Better collaboration** - Clear boundaries
✅ **Reusability** - Use case & repository in other features

### **Scalability**
✅ **Add new data sources** - Just implement FamilyRepositoryProtocol
✅ **Add new use cases** - Reuse existing repository
✅ **Add new views** - Reuse existing ViewModel
✅ **Switch databases** - No changes to ViewModel/UseCase

---

## 📝 Next Steps

1. **Add the new files to Xcode project**
2. **Update ContentView to use new ViewModel**
3. **Run tests** (create unit tests for each layer)
4. **Delete old PersonFormViewModel.swift**
5. **Celebrate!** 🎉

---

## 🏆 Comparison

### **Before:**
- 1 massive file (500+ lines)
- Mixed responsibilities
- Hard to test
- Tightly coupled

### **After:**
- 5 focused files (~600 lines total)
- Clear responsibilities
- Easy to test
- Loosely coupled
- **Better architecture!** ✨
