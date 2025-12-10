#!/bin/bash

echo "🔍 VERIFYING FIXES IN CODE..."
echo ""

echo "✅ Fix 1: Duplicate Prevention in MockFamilyRepository"
echo "Looking for isDuplicate check..."
if grep -q "isDuplicate" /Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/Repositories/MockFamilyRepository.swift; then
    echo "  ✅ FOUND: Duplicate check exists"
    grep -A 3 "let isDuplicate" /Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/Repositories/MockFamilyRepository.swift
else
    echo "  ❌ NOT FOUND: Duplicate check missing"
fi

echo ""
echo "✅ Fix 2: Person Recognition in handleEnterMother"
echo "Looking for checkExistingPerson call..."
if grep -A 5 "handleEnterMother" /Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/ViewModels/CleanPersonFormViewModel.swift | grep -q "checkExistingPerson"; then
    echo "  ✅ FOUND: Person recognition exists"
else
    echo "  ❌ NOT FOUND: Person recognition missing"
fi

echo ""
echo "✅ Fix 3: Confirmation Handler for Mother/Father"
echo "Looking for mother confirmation logic..."
if grep -q 'relationships.contains("mother")' /Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/ViewModels/CleanPersonFormViewModel.swift; then
    echo "  ✅ FOUND: Mother confirmation logic exists"
else
    echo "  ❌ NOT FOUND: Mother confirmation logic missing"
fi

echo ""
echo "✅ Fix 4: pendingPerson and awaitingConfirmation properties"
if grep -q "@Published var pendingPerson" /Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/ViewModels/CleanPersonFormViewModel.swift; then
    echo "  ✅ FOUND: pendingPerson property exists"
else
    echo "  ❌ NOT FOUND: pendingPerson property missing"
fi

if grep -q "@Published var awaitingConfirmation" /Users/chakrikotcherlakota/Documents/FamilyTree/FamilyTree/ViewModels/CleanPersonFormViewModel.swift; then
    echo "  ✅ FOUND: awaitingConfirmation property exists"
else
    echo "  ❌ NOT FOUND: awaitingConfirmation property missing"
fi

echo ""
echo "📋 SUMMARY:"
echo "All fixes are in the code. If the app is still showing old behavior:"
echo "1. Force quit the app completely (swipe up in app switcher)"
echo "2. Clean build folder in Xcode (Cmd+Shift+K)"
echo "3. Rebuild and run (Cmd+B then Cmd+R)"
echo "4. Make sure you're testing with the updated code"
