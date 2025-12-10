-- ====================================================================
-- SQL Script to Remove Duplicate Relationships from Supabase Database
-- ====================================================================
-- 
-- This script will:
-- 1. Show how many duplicates exist
-- 2. Remove all duplicate relationships (keeping only the first)
-- 3. Verify the cleanup was successful
--
-- Run this in your Supabase SQL Editor
-- ====================================================================

-- STEP 1: Check for duplicates BEFORE cleanup
-- --------------------------------------------------------------------
SELECT 
  p.full_name,
  rp.full_name as related_person_name,
  r.type,
  COUNT(*) as duplicate_count
FROM relationship r
JOIN person p ON r.person_id = p.id
JOIN person rp ON r.related_person_id = rp.id
GROUP BY p.full_name, rp.full_name, r.type
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Expected output example:
-- full_name      | related_person_name | type   | duplicate_count
-- Karunya Kumar  | Nirmala            | parent | 2
-- Karunya Kumar  | Srihari Rao        | parent | 2


-- STEP 2: Remove duplicate relationships
-- --------------------------------------------------------------------
-- This keeps the FIRST occurrence of each unique relationship
-- and deletes all others
-- --------------------------------------------------------------------
WITH ranked_relationships AS (
  SELECT 
    id,
    person_id,
    related_person_id,
    type,
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY person_id, related_person_id, type 
      ORDER BY created_at ASC  -- Keep the oldest one
    ) as row_num
  FROM relationship
)
DELETE FROM relationship
WHERE id IN (
  SELECT id 
  FROM ranked_relationships 
  WHERE row_num > 1  -- Delete all except the first
);

-- This will output: "DELETE X" where X is the number of duplicates removed


-- STEP 3: Verify cleanup - check for remaining duplicates
-- --------------------------------------------------------------------
SELECT 
  p.full_name,
  rp.full_name as related_person_name,
  r.type,
  COUNT(*) as count
FROM relationship r
JOIN person p ON r.person_id = p.id
JOIN person rp ON r.related_person_id = rp.id
GROUP BY p.full_name, rp.full_name, r.type
HAVING COUNT(*) > 1;

-- Expected output: (empty table = no duplicates remain!)


-- STEP 4: Show summary of relationships for Karunya Kumar
-- --------------------------------------------------------------------
SELECT 
  p.full_name as person,
  rp.full_name as related_to,
  r.type as relationship_type,
  r.created_at
FROM relationship r
JOIN person p ON r.person_id = p.id
JOIN person rp ON r.related_person_id = rp.id
WHERE p.full_name = 'Karunya Kumar'
ORDER BY r.type, rp.full_name;

-- Expected output for Karunya Kumar:
-- person         | related_to       | relationship_type | created_at
-- Karunya Kumar  | Nirmala         | parent           | 2024-12-09 ...
-- Karunya Kumar  | Srihari Rao     | parent           | 2024-12-09 ...
-- Karunya Kumar  | Lavanya Kumar   | sibling          | 2024-12-09 ...
-- (Only ONE of each relationship!)


-- STEP 5: Get total relationship counts
-- --------------------------------------------------------------------
SELECT 
  p.full_name,
  COUNT(CASE WHEN r.type = 'parent' THEN 1 END) as parent_count,
  COUNT(CASE WHEN r.type = 'spouse' THEN 1 END) as spouse_count,
  COUNT(CASE WHEN r.type = 'sibling' THEN 1 END) as sibling_count,
  COUNT(*) as total_relationships
FROM person p
LEFT JOIN relationship r ON r.person_id = p.id
WHERE p.full_name = 'Karunya Kumar'
GROUP BY p.full_name;

-- Expected output:
-- full_name      | parent_count | spouse_count | sibling_count | total_relationships
-- Karunya Kumar  | 2            | 0            | 2             | 4
-- (Should show 2 parents, not 4!)


-- ====================================================================
-- ALTERNATIVE: Delete specific person and start fresh
-- ====================================================================
-- If you want to completely remove Karunya Kumar and re-add them:
-- ====================================================================

-- STEP 1: Delete all relationships involving Karunya Kumar
/*
DELETE FROM relationship 
WHERE person_id IN (
  SELECT id FROM person WHERE full_name = 'Karunya Kumar' AND birth_year = 1970
)
OR related_person_id IN (
  SELECT id FROM person WHERE full_name = 'Karunya Kumar' AND birth_year = 1970
);
*/

-- STEP 2: Delete the person record
/*
DELETE FROM person 
WHERE full_name = 'Karunya Kumar' AND birth_year = 1970;
*/

-- Then re-add them through the app with the fixed code!


-- ====================================================================
-- PREVENTION: Add unique constraint (optional but recommended)
-- ====================================================================
-- This will prevent duplicates at the database level
-- ====================================================================

-- Create unique index to prevent duplicate relationships
/*
CREATE UNIQUE INDEX IF NOT EXISTS unique_relationships 
ON relationship (person_id, related_person_id, type);
*/

-- Note: Run this AFTER cleaning up duplicates
-- This ensures no duplicates can ever be created in the future


-- ====================================================================
-- VERIFICATION QUERIES
-- ====================================================================

-- Check all people and their relationship counts
SELECT 
  p.full_name,
  p.birth_year,
  COUNT(CASE WHEN r.type = 'parent' THEN 1 END) as parents,
  COUNT(CASE WHEN r.type = 'spouse' THEN 1 END) as spouses,
  COUNT(CASE WHEN r.type = 'sibling' THEN 1 END) as siblings
FROM person p
LEFT JOIN relationship r ON r.person_id = p.id
GROUP BY p.id, p.full_name, p.birth_year
ORDER BY p.full_name;

-- Show all duplicate relationships across entire database
SELECT 
  person_id,
  related_person_id,
  type,
  COUNT(*) as duplicate_count,
  ARRAY_AGG(id) as relationship_ids
FROM relationship
GROUP BY person_id, related_person_id, type
HAVING COUNT(*) > 1;
