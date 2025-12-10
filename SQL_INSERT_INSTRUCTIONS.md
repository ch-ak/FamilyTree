# ✅ SQL Insert Instructions - Fixed!

## Issues Fixed

### 1. **Truncated UUID** ❌→✅
- **Problem**: Venkatappaiah's UUID was missing last character: `8da2d0da-a924-473c-8b63-f26a66b34b5`
- **Fixed**: `8da2d0da-a924-473c-8b63-f26a66b34b50`

### 2. **Duplicate UUIDs** ❌→✅
- **Problem**: Kanakamma and Sloka shared UUID `507ae6b8-7ebc-44ce-9ce5-5bea808f4fca`
- **Fixed**: 
  - Kanakamma: `507ae6b8-7ebc-44ce-9ce5-5bea808f4fca`
  - Sloka: `f8a9b0c1-d2e3-f4a5-b6c7-d8e9f0a1b2c3` (new unique UUID)

### 3. **Duplicate UUIDs** ❌→✅
- **Problem**: Narasamma and Rishi shared UUID `fd2acba9-8b7c-4758-bb20-328db962074d`
- **Fixed**:
  - Narasamma: `fd2acba9-8b7c-4758-bb20-328db962074d`
  - Rishi: `a9b0c1d2-e3f4-a5b6-c7d8-e9f0a1b2c3d4` (new unique UUID)

---

## How to Run the SQL in Supabase

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click **SQL Editor** in the left sidebar
3. Click **New query**

### Step 2: Optional - Clear Existing Data
If you want to start fresh, run this first:
```sql
DELETE FROM relationship;
DELETE FROM person;
```

### Step 3: Run the Insert Script
1. Open the file: `insert_family_data.sql`
2. Copy ALL the content
3. Paste into Supabase SQL Editor
4. Click **Run** (or press Cmd+Enter)

### Step 4: Verify the Data
Run these queries to check:

```sql
-- Count people
SELECT COUNT(*) as total_people FROM person;
-- Should return ~82 people

-- Count relationships  
SELECT COUNT(*) as total_relationships FROM relationship;
-- Should return 100+ relationships

-- Check a specific person
SELECT * FROM person WHERE full_name = 'Sloka Kocherlakota';
-- Should show birth_year = 2005

-- Check relationships for Sloka
SELECT 
  p.full_name,
  r.type
FROM relationship r
JOIN person p ON r.related_person_id = p.id
WHERE r.person_id = (SELECT id FROM person WHERE full_name = 'Sloka Kocherlakota');
-- Should show parents: Srinivasa Chakravarthy and Sujana, sibling: Rishi
```

---

## Data Summary

### People by Generation:
- **Gen I**: 1 person (Subbaayudu - 1800)
- **Gen II**: 2 people (Venkatappaiah + spouse - 1830s)
- **Gen III**: 8 people (Venkatappaiah's children - 1860-1881)
- **Gen IV**: 17 people (Kanakamma's children - 1890-1938)
- **Gen V**: 23 people (Multiple branches - 1920-1969)
- **Gen VI**: 14 people (Subbarao's children - 1965-2004)
- **Gen VII**: 2 people (Sloka & Rishi - 2005-2008)
- **Spouses**: 3 additional people

**Total**: ~82 people across 208 years (1800-2008)

### Relationship Types:
- **PARENT**: Parent → Child links
- **SIBLING**: Bidirectional sibling links
- **SPOUSE**: Bidirectional marriage links

---

## Troubleshooting

### If you get "duplicate key value" error:
This means the person/relationship already exists. Either:
1. Run the DELETE queries first (Step 2)
2. Or manually delete conflicting records

### If you get "invalid UUID" error:
- Make sure you copied the ENTIRE SQL file
- Check that no line breaks were corrupted during copy/paste

### If relationships don't show up:
- Make sure BOTH person records exist before creating relationship
- Relationships reference person IDs, so persons must be inserted first

---

## Next Steps

After running the SQL:

1. **Test in your iOS app**:
   - Build and run the FamilyTree app
   - Switch to using real data (disable mock data)
   - Navigate to Full Tree tab
   - Search for "Sloka Kocherlakota" or "Kanakamma"

2. **Add more data**:
   - Add missing siblings relationships
   - Add more spouse information
   - Add additional family members

3. **Query examples**:
```sql
-- Find all children of Kanakamma
SELECT p.full_name, p.birth_year
FROM person p
JOIN relationship r ON p.id = r.person_id
WHERE r.related_person_id = (SELECT id FROM person WHERE full_name = 'Kanakamma')
AND r.type = 'PARENT'
ORDER BY p.birth_year;

-- Find all siblings of Parthasarathy  
SELECT p.full_name, p.birth_year
FROM person p
JOIN relationship r ON p.id = r.related_person_id
WHERE r.person_id = (SELECT id FROM person WHERE full_name = 'Parthasarathy')
AND r.type = 'SIBLING'
ORDER BY p.birth_year;
```

---

**Status**: ✅ Ready to run!  
**File**: `insert_family_data.sql`  
**Last Updated**: December 6, 2025
