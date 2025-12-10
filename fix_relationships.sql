-- ═══════════════════════════════════════════════════════════
-- FIX MISSING BIDIRECTIONAL RELATIONSHIPS
-- Run this in Supabase SQL Editor to fix existing data
-- ═══════════════════════════════════════════════════════════

-- STEP 1: Fix missing CHILD relationships
-- (Where parent has YOU/SISTER as PARENT, but parent doesn't have CHILD link back)
-- ═══════════════════════════════════════════════════════════

INSERT INTO relationship (person_id, related_person_id, type)
SELECT DISTINCT 
    r.related_person_id as person_id,      -- The parent
    r.person_id as related_person_id,      -- The child (you/sister)
    'CHILD' as type
FROM relationship r
WHERE r.type = 'PARENT'
AND NOT EXISTS (
    -- Check if reverse CHILD relationship already exists
    SELECT 1 FROM relationship r2
    WHERE r2.person_id = r.related_person_id
    AND r2.related_person_id = r.person_id
    AND r2.type = 'CHILD'
);

-- STEP 2: Fix missing PARENT relationships  
-- (Where parent has CHILD, but child doesn't have PARENT link back)
-- ═══════════════════════════════════════════════════════════

INSERT INTO relationship (person_id, related_person_id, type)
SELECT DISTINCT 
    r.related_person_id as person_id,      -- The child
    r.person_id as related_person_id,      -- The parent
    'PARENT' as type
FROM relationship r
WHERE r.type = 'CHILD'
AND NOT EXISTS (
    -- Check if reverse PARENT relationship already exists
    SELECT 1 FROM relationship r2
    WHERE r2.person_id = r.related_person_id
    AND r2.related_person_id = r.person_id
    AND r2.type = 'PARENT'
);

-- STEP 3: Fix missing SIBLING relationships
-- (Make all sibling relationships bidirectional)
-- ═══════════════════════════════════════════════════════════

INSERT INTO relationship (person_id, related_person_id, type)
SELECT DISTINCT 
    r.related_person_id as person_id,      -- Sibling B
    r.person_id as related_person_id,      -- Sibling A
    'SIBLING' as type
FROM relationship r
WHERE r.type = 'SIBLING'
AND NOT EXISTS (
    -- Check if reverse SIBLING relationship already exists
    SELECT 1 FROM relationship r2
    WHERE r2.person_id = r.related_person_id
    AND r2.related_person_id = r.person_id
    AND r2.type = 'SIBLING'
);

-- STEP 4: Fix missing SPOUSE relationships
-- (Make all spouse relationships bidirectional)
-- ═══════════════════════════════════════════════════════════

INSERT INTO relationship (person_id, related_person_id, type)
SELECT DISTINCT 
    r.related_person_id as person_id,      -- Spouse B
    r.person_id as related_person_id,      -- Spouse A
    'SPOUSE' as type
FROM relationship r
WHERE r.type = 'SPOUSE'
AND NOT EXISTS (
    -- Check if reverse SPOUSE relationship already exists
    SELECT 1 FROM relationship r2
    WHERE r2.person_id = r.related_person_id
    AND r2.related_person_id = r.person_id
    AND r2.type = 'SPOUSE'
);

-- ═══════════════════════════════════════════════════════════
-- VERIFICATION QUERIES
-- Run these to check that relationships are now complete
-- ═══════════════════════════════════════════════════════════

-- Check 1: Count parent-child relationships (should be balanced)
SELECT 
    'PARENT links' as type,
    COUNT(*) as count
FROM relationship 
WHERE type = 'PARENT'
UNION ALL
SELECT 
    'CHILD links' as type,
    COUNT(*) as count
FROM relationship 
WHERE type = 'CHILD';
-- These should be equal!

-- Check 2: Find any unbalanced parent-child relationships
SELECT 
    p1.full_name as parent,
    p2.full_name as child,
    'Missing CHILD link' as issue
FROM relationship r
JOIN person p1 ON r.person_id = p1.id
JOIN person p2 ON r.related_person_id = p2.id
WHERE r.type = 'PARENT'
AND NOT EXISTS (
    SELECT 1 FROM relationship r2
    WHERE r2.person_id = p1.id
    AND r2.related_person_id = p2.id
    AND r2.type = 'CHILD'
)
UNION ALL
SELECT 
    p2.full_name as parent,
    p1.full_name as child,
    'Missing PARENT link' as issue
FROM relationship r
JOIN person p1 ON r.person_id = p1.id
JOIN person p2 ON r.related_person_id = p2.id
WHERE r.type = 'CHILD'
AND NOT EXISTS (
    SELECT 1 FROM relationship r2
    WHERE r2.person_id = p2.id
    AND r2.related_person_id = p1.id
    AND r2.type = 'PARENT'
);
-- Should return 0 rows!

-- Check 3: View all relationships for a specific person (replace name)
SELECT 
    p1.full_name as person,
    r.type,
    p2.full_name as related_to
FROM relationship r
JOIN person p1 ON r.person_id = p1.id
JOIN person p2 ON r.related_person_id = p2.id
WHERE p1.full_name LIKE '%YOUR_NAME_HERE%'
ORDER BY r.type, p2.full_name;

-- Check 4: Verify your mother has you and sister as CHILD
SELECT 
    p1.full_name as mother,
    r.type,
    p2.full_name as child
FROM relationship r
JOIN person p1 ON r.person_id = p1.id
JOIN person p2 ON r.related_person_id = p2.id
WHERE p1.full_name LIKE '%MOTHER_NAME_HERE%'
AND r.type = 'CHILD'
ORDER BY p2.birth_year;
-- Should show you and your sister!

-- ═══════════════════════════════════════════════════════════
-- SUMMARY
-- ═══════════════════════════════════════════════════════════
-- 
-- This script:
-- 1. Adds missing CHILD relationships for all PARENT relationships
-- 2. Adds missing PARENT relationships for all CHILD relationships
-- 3. Adds missing reverse SIBLING relationships
-- 4. Adds missing reverse SPOUSE relationships
-- 
-- After running this:
-- - Your mother will show YOU and SISTER as children ✓
-- - Your father will show YOU and SISTER as children ✓
-- - You will show MOTHER and FATHER as parents ✓
-- - Your sister will show MOTHER and FATHER as parents ✓
-- - All sibling relationships will be bidirectional ✓
-- - All spouse relationships will be bidirectional ✓
-- 
-- ═══════════════════════════════════════════════════════════
