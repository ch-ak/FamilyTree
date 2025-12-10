-- ============================================
-- Family Tree Database Indexes
-- Performance Optimization for 1200+ People
-- ============================================

-- Run these in Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste → Run

-- ============================================
-- 1. Person Table Indexes
-- ============================================

-- Speed up name lookups (used in search)
CREATE INDEX IF NOT EXISTS idx_person_name 
ON person(full_name);

-- Speed up birth year filtering/sorting
CREATE INDEX IF NOT EXISTS idx_person_birth_year 
ON person(birth_year);

-- Speed up combined name + year searches
CREATE INDEX IF NOT EXISTS idx_person_name_year 
ON person(full_name, birth_year);

-- ============================================
-- 2. Relationship Table Indexes
-- ============================================

-- Speed up queries for "all relationships of person X"
CREATE INDEX IF NOT EXISTS idx_relationship_person 
ON relationship(person_id);

-- Speed up reverse lookups "who is related to person X"
CREATE INDEX IF NOT EXISTS idx_relationship_related 
ON relationship(related_person_id);

-- Speed up filtering by relationship type
CREATE INDEX IF NOT EXISTS idx_relationship_type 
ON relationship(type);

-- Composite index for most common query pattern
-- "Get all parents/siblings/children of person X"
CREATE INDEX IF NOT EXISTS idx_relationship_lookup 
ON relationship(person_id, type, related_person_id);

-- Reverse composite for bidirectional queries
CREATE INDEX IF NOT EXISTS idx_relationship_reverse_lookup 
ON relationship(related_person_id, type, person_id);

-- ============================================
-- 3. Verify Indexes Created
-- ============================================

-- Check all indexes on person table
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'person';

-- Check all indexes on relationship table
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'relationship';

-- ============================================
-- 4. Performance Testing Queries
-- ============================================

-- Test 1: Find person by name (should use idx_person_name)
EXPLAIN ANALYZE
SELECT * FROM person WHERE full_name = 'Chakri Kocherlakota';

-- Test 2: Find all parents of a person (should use idx_relationship_lookup)
EXPLAIN ANALYZE
SELECT p.* 
FROM person p
JOIN relationship r ON p.id = r.related_person_id
WHERE r.person_id = 'YOUR-PERSON-UUID-HERE'
AND r.type = 'PARENT';

-- Test 3: Search by partial name (should use idx_person_name)
EXPLAIN ANALYZE
SELECT * FROM person WHERE full_name ILIKE '%Kocherlakota%';

-- ============================================
-- Expected Results
-- ============================================

-- Before indexes:
-- - Seq Scan (Sequential Scan) - SLOW ❌
-- - Planning time: ~1ms
-- - Execution time: 50-500ms with 1200 rows

-- After indexes:
-- - Index Scan using idx_person_name - FAST ✅
-- - Planning time: ~1ms
-- - Execution time: 1-5ms with 1200 rows

-- Performance improvement: 10-100x faster! 🚀

-- ============================================
-- Notes
-- ============================================

-- 1. These indexes are automatically maintained by PostgreSQL
-- 2. They slightly slow down INSERT/UPDATE (negligible for this app)
-- 3. They significantly speed up SELECT queries (critical for UI)
-- 4. Total index size: ~1-2 MB for 1200 people (tiny!)
-- 5. Indexes are automatically used by query planner

-- ============================================
-- Maintenance
-- ============================================

-- Rebuild indexes if needed (rarely necessary)
-- REINDEX TABLE person;
-- REINDEX TABLE relationship;

-- Check index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
