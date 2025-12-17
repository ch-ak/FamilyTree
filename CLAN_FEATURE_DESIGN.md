# 🏘️ Clan Feature Design - Implementation Plan

## Date: December 10, 2025

## Vision & Goals

### Long-term Vision
**Goal**: Link all ancestors across 20+ clans and eventually find connections between all family lines.

### Current Situation
- 20 clans organized by **location**
- Each clan has a known **patriarch** (founder)
- Many ancestors still unlinked
- Need organized way to manage and grow each clan's data

---

## 📋 Proposed Architecture

### Phase 1: Clan Table & Selection (First Implementation)

#### Database Structure

```sql
-- Clan master table (hardcoded/pre-populated)
CREATE TABLE clan (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  location TEXT NOT NULL,  -- Location-based clan identification
  patriarch_name TEXT,     -- Known founder/patriarch of this clan
  patriarch_birth_year INT,
  description TEXT,
  origin_story TEXT,       -- History of this clan/branch
  created_at TIMESTAMP DEFAULT NOW()
);

-- Link people to their clan
CREATE TABLE person_clan (
  person_id UUID REFERENCES person(id) ON DELETE CASCADE,
  clan_id UUID REFERENCES clan(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT true,  -- Main clan (vs. spouse's clan)
  joined_by_marriage BOOLEAN DEFAULT false,
  PRIMARY KEY (person_id, clan_id)
);

-- Index for faster queries
CREATE INDEX idx_person_clan_person ON person_clan(person_id);
CREATE INDEX idx_person_clan_clan ON person_clan(clan_id);
```

#### Pre-populate Clan Table

```sql
-- Example: Insert your 20 clans (hardcoded)
INSERT INTO clan (name, location, patriarch_name, patriarch_birth_year, description) VALUES
  ('Kocherlakota - Hyderabad', 'Hyderabad', 'Subbaayudu', 1800, 'Main Kocherlakota family line based in Hyderabad'),
  ('Kocherlakota - Guntur', 'Guntur', 'Venkatappaiah', 1830, 'Guntur branch of Kocherlakota family'),
  ('Kocherlakota - Vijayawada', 'Vijayawada', 'Parthasarathy', 1850, 'Vijayawada branch'),
  -- ... add all 20 clans here
  ;
```

---

## 🎨 User Interface Flow

### New Screen: Clan Selection (After Splash Screen)

```
┌─────────────────────────────────────────┐
│                                         │
│        Welcome to Family Tree           │
│                                         │
│    Which clan do you belong to?         │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🏘️ Kocherlakota - Hyderabad     │  │
│  │    Patriarch: Subbaayudu (1800)  │  │
│  │    📍 Hyderabad                  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🏘️ Kocherlakota - Guntur        │  │
│  │    Patriarch: Venkatappaiah      │  │
│  │    📍 Guntur                     │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ 🏘️ Kocherlakota - Vijayawada    │  │
│  │    Patriarch: Parthasarathy      │  │
│  │    📍 Vijayawada                 │  │
│  └───────────────────────────────────┘  │
│                                         │
│        [Show All 20 Clans ▼]            │
│                                         │
│     [Not Sure / Browse All]             │
│                                         │
└─────────────────────────────────────────┘
```

### Flow

1. **Splash Screen** (existing)
   ↓
2. **NEW: Clan Selection Screen** 
   - Shows all 20 clans in scrollable list
   - Each clan card shows:
     - Clan name (with location)
     - Patriarch name & birth year
     - Location icon
     - Brief description
   - User selects their clan
   - OR: "Not Sure" → goes to browse mode
   ↓
3. **Chat Wizard** (existing)
   - Now knows user's clan
   - Auto-assigns clan to all people added
   - Can override if needed (inter-clan marriages)

---

## 🔄 Data Flow

### When User Selects Clan

1. Store selected `clan_id` in local state (UserDefaults or app state)
2. When adding people through Chat Wizard:
   - Automatically link to selected clan
   - Create entry in `person_clan` table
3. When adding spouse from different clan:
   - Ask: "Is [spouse] from the same clan or different?"
   - If different: Show clan selector again
   - Link spouse to their clan

### Inheritance Rules

```
Person's Clan Assignment:
  1. If added through Chat Wizard:
     → Use session's selected clan
  
  2. If child of existing parents:
     → Inherit father's primary clan (traditional)
     → OR: Ask user which parent's clan to follow
  
  3. If spouse from different clan:
     → Keep original clan as primary
     → Add spouse's clan as secondary (joined_by_marriage=true)
```

---

## 📊 Features by Phase

### Phase 1: Basic Clan Selection (Implement First)

**Database:**
- ✅ Create `clan` table
- ✅ Create `person_clan` table
- ✅ Hardcode 20 clans
- ✅ Add indexes

**UI:**
- ✅ Clan selection screen after splash
- ✅ Display all clans with patriarch info
- ✅ Store selected clan in session

**Chat Wizard:**
- ✅ Auto-assign clan to new people
- ✅ Ask for spouse's clan if different

**WHO Tab:**
- ✅ Show clan name with each person
- ✅ Add clan filter dropdown

**Estimated Time:** 6-8 hours

---

### Phase 2: Clan Visualization (Later)

**Features:**
- Separate tab for each clan's tree
- Filter D3 tree by clan
- Color-code by clan
- Clan statistics (member count, generations, etc.)

**Estimated Time:** 8-10 hours

---

### Phase 3: Inter-Clan Linking (Long-term Goal)

**Features:**
- Find common ancestors between clans
- Visualize connections between clans
- Merge duplicate people across clans
- Build complete family tree across all 20 clans

**Estimated Time:** 20+ hours

---

## 💾 Data Model

### Clan Entity
```swift
struct Clan: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: String
    let patriarchName: String?
    let patriarchBirthYear: Int?
    let description: String?
    let originStory: String?
}
```

### PersonClan Relationship
```swift
struct PersonClan: Identifiable, Codable {
    let id: UUID
    let personId: UUID
    let clanId: UUID
    let isPrimary: Bool
    let joinedByMarriage: Bool
}
```

---

## 🎯 Screen Layouts

### Clan Selection Screen Components

1. **Header**
   ```
   Welcome to Kocherlakota Family Tree
   Select your family clan/branch
   ```

2. **Clan List (Scrollable)**
   ```swift
   ForEach(clans) { clan in
       ClanCard(clan: clan) {
           selectedClan = clan
           navigateToWizard()
       }
   }
   ```

3. **Clan Card Design**
   ```
   ┌─────────────────────────────────────┐
   │ 🏘️ [Clan Name]                     │
   │ 📍 Location: [Location]            │
   │ 👴 Patriarch: [Name] ([Year])      │
   │ 📝 [Brief description...]          │
   │                                    │
   │           [Select Clan →]          │
   └─────────────────────────────────────┘
   ```

4. **Footer**
   ```
   [Not Sure? Browse All People]
   [Skip - I'll select later]
   ```

---

## 🔍 Search & Filter Enhancements

### WHO Tab with Clan Filter

```
┌─────────────────────────────────────────┐
│  Search: [____________]  Year: [____]   │
│  Clan: [All Clans ▼]                    │
│                                         │
│  Dropdown:                              │
│    • All Clans                          │
│    • Kocherlakota - Hyderabad          │
│    • Kocherlakota - Guntur             │
│    • Kocherlakota - Vijayawada         │
│    • ... (all 20 clans)                │
└─────────────────────────────────────────┘
```

### Display with Clan Info

```
Search Results:

📱 Karunya Kumar (1970)
   🏘️ Kocherlakota - Hyderabad
   👨‍👩 Parents: Nirmala, Srihari Rao
   👨‍👩‍👧‍👦 Siblings: Lavanya Kumar

📱 Lavanya Kumar (1971)
   🏘️ Kocherlakota - Hyderabad
   👨‍👩 Parents: Nirmala, Srihari Rao
   👨‍👩‍👧‍👦 Siblings: Karunya Kumar
```

---

## 🎨 Color Coding Strategy

### Assign Each Clan a Color

```swift
let clanColors: [String: Color] = [
    "Kocherlakota - Hyderabad": .blue,
    "Kocherlakota - Guntur": .green,
    "Kocherlakota - Vijayawada": .orange,
    "Kocherlakota - Chennai": .purple,
    // ... assign all 20 clans
]
```

### Use in D3 Tree

```javascript
// Color nodes by clan
nodes.forEach(node => {
    node.color = clanColors[node.clan_name] || '#cccccc';
});
```

---

## 📝 Chat Wizard Updates

### New Question Flow

```
Step 1: Clan already selected from Clan Selection screen
        (stored in session)

Step 2: "What is your full name and year of birth?"
        → Chakri, 2000

Step 3: "What is your mother's name?"
        → Nirmala, 1947
        → Check if Nirmala exists
        → If yes: Check her clan
        → If different from session clan:
           "Nirmala belongs to [Other Clan]. Is this your mother?"

Step 4: Continue as before...

When adding spouse:
   "What is your spouse's name?"
   → Sujana, 1973
   → "Is Sujana from the same clan or different?"
   → If different: "Which clan?"
      → Show clan selector
      → Link spouse to their clan
```

---

## 🗄️ Repository Methods Needed

```swift
protocol ClanRepositoryProtocol {
    // Fetch all clans
    func fetchAllClans() async throws -> [Clan]
    
    // Get clan by ID
    func getClan(id: UUID) async throws -> Clan?
    
    // Get person's clans
    func getPersonClans(personId: UUID) async throws -> [Clan]
    
    // Link person to clan
    func linkPersonToClan(
        personId: UUID, 
        clanId: UUID, 
        isPrimary: Bool,
        joinedByMarriage: Bool
    ) async throws
    
    // Get all people in a clan
    func getPeopleInClan(clanId: UUID) async throws -> [Person]
    
    // Get clan statistics
    func getClanStats(clanId: UUID) async throws -> ClanStats
}

struct ClanStats {
    let totalMembers: Int
    let generations: Int
    let oldestMember: Person?
    let youngestMember: Person?
}
```

---

## 🎯 Implementation Checklist

### Phase 1 Tasks (When Ready to Implement)

**Database:**
- [ ] Create `clan` table in Supabase
- [ ] Create `person_clan` table in Supabase
- [ ] Insert 20 hardcoded clans with location & patriarch data
- [ ] Add indexes for performance
- [ ] Create views for clan statistics

**Models:**
- [ ] Create `Clan.swift` model
- [ ] Create `PersonClan.swift` model
- [ ] Update `Person.swift` to include clan info

**Repository:**
- [ ] Create `ClanRepository.swift`
- [ ] Implement `fetchAllClans()`
- [ ] Implement `linkPersonToClan()`
- [ ] Implement `getPersonClans()`
- [ ] Update `MockFamilyRepository` with clan support

**UI - Clan Selection:**
- [ ] Create `ClanSelectionView.swift`
- [ ] Create `ClanCardView.swift` component
- [ ] Create `ClanViewModel.swift`
- [ ] Add navigation from splash to clan selection
- [ ] Store selected clan in UserDefaults/AppState

**UI - Chat Wizard:**
- [ ] Update to auto-assign clan to new people
- [ ] Add spouse clan question
- [ ] Update confirmation messages to show clan

**UI - WHO Tab:**
- [ ] Add clan filter dropdown
- [ ] Display clan name with each person
- [ ] Add clan icon/badge

**UI - D3 Tree:**
- [ ] Color-code nodes by clan
- [ ] Add clan legend
- [ ] Add clan filter toggle

**Testing:**
- [ ] Test clan selection flow
- [ ] Test auto-assignment in wizard
- [ ] Test inter-clan marriages
- [ ] Test WHO tab filtering
- [ ] Test D3 tree color coding

---

## 📦 File Structure

```
FamilyTree/
├── Models/
│   ├── Clan.swift                    [NEW]
│   └── PersonClan.swift               [NEW]
│
├── Repositories/
│   ├── ClanRepository.swift           [NEW]
│   └── MockClanRepository.swift       [NEW]
│
├── ViewModels/
│   ├── ClanSelectionViewModel.swift   [NEW]
│   └── CleanPersonFormViewModel.swift [UPDATE]
│
├── Views/
│   ├── ClanSelectionView.swift        [NEW]
│   ├── ClanCardView.swift             [NEW]
│   ├── WhoAmIView.swift               [UPDATE]
│   └── ChatWizardView.swift           [UPDATE]
│
└── Managers/
    └── ClanManager.swift              [NEW]
```

---

## 🌟 Benefits of This Approach

1. **Scalable**
   - Easy to add more clans later
   - Supports unlimited people per clan
   - Can handle inter-clan connections

2. **User-Friendly**
   - Clear visual clan selection
   - Shows patriarch context (helps identify correct clan)
   - Location-based identification is intuitive

3. **Data Integrity**
   - Hardcoded clan table prevents typos
   - Relationship table allows flexibility
   - Can track marriage connections between clans

4. **Future-Proof**
   - Foundation for inter-clan linking
   - Can add clan hierarchy later
   - Supports finding common ancestors

5. **Performance**
   - Indexed queries for fast filtering
   - Efficient clan-based searches
   - Cached clan list (20 items)

---

## 💡 Advanced Features (Phase 3+)

### Clan Dashboard
```
Kocherlakota - Hyderabad Clan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Statistics:
   • Total Members: 145
   • Generations: 7
   • Oldest: Subbaayudu (1800)
   • Newest: Baby Kocherlakota (2024)

👥 Demographics:
   • Living: 98
   • Deceased: 47
   • Males: 73
   • Females: 72

🔗 Connections:
   • Marriages with Guntur clan: 5
   • Marriages with Vijayawada clan: 3

[View Full Tree →]
```

### Inter-Clan Connection Finder
```
Find Common Ancestors

Clan 1: [Hyderabad ▼]
Clan 2: [Guntur ▼]

[Find Connections]

Results:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 Found 3 connections:

1. Subbaayudu (1800)
   ↓
   Common ancestor of both clans

2. Venkatappaiah married Lakshmi from Guntur
   ↓
   Marriage connection, 1850

3. Parthasarathy's daughter married into Guntur
   ↓
   Marriage connection, 1875
```

---

## 🎓 Long-term Vision: The Complete Family Tree

**Ultimate Goal:**
```
          Kocherlakota Root Ancestor
                    ↓
        ┌───────────┼───────────┐
        ↓           ↓           ↓
    Hyderabad   Guntur    Vijayawada
    (20 clans eventually linked)
        ↓           ↓           ↓
    [145 people] [98 people] [76 people]
        ↓           ↓           ↓
    All connected through marriages & ancestry
```

**What This Enables:**
1. Find how any two people in family are related
2. See complete lineage from any ancestor to present
3. Discover new connections between clan branches
4. Preserve complete family history for future generations

---

## ✅ Ready for Implementation

This design is:
- ✅ Well-defined and structured
- ✅ Scalable for 20+ clans
- ✅ Fits existing app architecture
- ✅ Supports long-term vision
- ✅ User-friendly interface
- ✅ Performance-optimized

**When you're ready to implement, this document has everything needed to start!**

---

## 📞 Questions to Answer Before Implementation

1. **Clan Names:** Can you provide the exact names and locations of all 20 clans?
2. **Patriarchs:** Do you know the patriarch (founder) name and birth year for each?
3. **Descriptions:** Brief description for each clan? (origin story, significance)
4. **Selection Required:** Should clan selection be mandatory or optional?
5. **Clan Switching:** Can users switch clans later or is it permanent?

**Save this document - it's your complete implementation blueprint!** 🎯
