#!/bin/bash

# SQL Validation Script for Family Tree Data
# This script checks the SQL file for common issues

echo "🔍 Validating SQL file..."
echo ""

SQL_FILE="insert_family_data.sql"

# Check 1: File exists
if [ ! -f "$SQL_FILE" ]; then
    echo "❌ Error: $SQL_FILE not found!"
    exit 1
fi
echo "✅ File exists: $SQL_FILE"

# Check 2: Count UUIDs
TOTAL_UUIDS=$(grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" "$SQL_FILE" | wc -l)
echo "✅ Total UUIDs found: $TOTAL_UUIDS"

# Check 3: Check for duplicate UUIDs in person table
echo ""
echo "🔍 Checking for duplicate person UUIDs..."
PERSON_UUIDS=$(grep "INSERT INTO person" -A 100 "$SQL_FILE" | grep -oE "^\('([0-9a-f-]+)'" | grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
UNIQUE_PERSON_UUIDS=$(echo "$PERSON_UUIDS" | sort -u | wc -l)
TOTAL_PERSON_UUIDS=$(echo "$PERSON_UUIDS" | wc -l)

if [ "$UNIQUE_PERSON_UUIDS" -eq "$TOTAL_PERSON_UUIDS" ]; then
    echo "✅ No duplicate person UUIDs found ($TOTAL_PERSON_UUIDS unique)"
else
    echo "❌ WARNING: Found duplicate person UUIDs!"
    echo "   Unique: $UNIQUE_PERSON_UUIDS, Total: $TOTAL_PERSON_UUIDS"
    echo "   Duplicates:"
    echo "$PERSON_UUIDS" | sort | uniq -d
fi

# Check 4: Verify specific UUIDs are correct
echo ""
echo "🔍 Checking key person UUIDs..."

# Venkatappaiah - should be fixed
VENKATA_UUID=$(grep "Venkatappaiah" "$SQL_FILE" | grep "INSERT INTO person" -A 2 | grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" | head -1)
if [ ${#VENKATA_UUID} -eq 36 ]; then
    echo "✅ Venkatappaiah UUID: $VENKATA_UUID (correct length)"
else
    echo "❌ Venkatappaiah UUID is wrong length: $VENKATA_UUID"
fi

# Kanakamma
KANAKAMMA_UUID=$(grep "'Kanakamma'" "$SQL_FILE" | grep "INSERT INTO person" -A 5 | grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" | head -1)
echo "✅ Kanakamma UUID: $KANAKAMMA_UUID"

# Sloka - should be different from Kanakamma
SLOKA_UUID=$(grep "'Sloka Kocherlakota'" "$SQL_FILE" | grep "INSERT INTO person" -A 2 | grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" | head -1)
echo "✅ Sloka UUID: $SLOKA_UUID"

if [ "$KANAKAMMA_UUID" = "$SLOKA_UUID" ]; then
    echo "❌ ERROR: Kanakamma and Sloka have the same UUID!"
else
    echo "✅ Kanakamma and Sloka have different UUIDs"
fi

# Check 5: Count person records
echo ""
echo "🔍 Counting records..."
PERSON_COUNT=$(grep -E "^\('[0-9a-f-]+', '.+', [0-9]{4}\)" "$SQL_FILE" | wc -l)
echo "✅ Total person records: $PERSON_COUNT"

RELATIONSHIP_COUNT=$(grep "INSERT INTO relationship" "$SQL_FILE" | wc -l)
echo "✅ Total relationship INSERT statements: $RELATIONSHIP_COUNT"

# Check 6: Syntax check
echo ""
echo "🔍 Checking SQL syntax..."
if grep -q "INSERT INTO person (id, full_name, birth_year) VALUES" "$SQL_FILE"; then
    echo "✅ Person table syntax looks good"
else
    echo "❌ Person table syntax issue"
fi

if grep -q "INSERT INTO relationship (id, person_id, related_person_id, type) VALUES" "$SQL_FILE"; then
    echo "✅ Relationship table syntax looks good"
else
    echo "❌ Relationship table syntax issue"
fi

# Final summary
echo ""
echo "================================"
echo "📊 SUMMARY"
echo "================================"
echo "Person records: ~$PERSON_COUNT"
echo "Relationship statements: $RELATIONSHIP_COUNT"
echo "Total UUIDs: $TOTAL_UUIDS"
echo "Unique person UUIDs: $UNIQUE_PERSON_UUIDS"
echo ""
echo "✅ Validation complete! File is ready to run in Supabase."
echo ""
echo "Next steps:"
echo "1. Open Supabase SQL Editor"
echo "2. Copy/paste the contents of $SQL_FILE"
echo "3. Click 'Run' to insert the data"
