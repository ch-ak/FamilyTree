import Foundation

// MARK: - Real Kocherlakota Family Mock Data
// Based on actual family tree structure provided

final class RealFamilyMockDataGenerator {
    
    // MARK: - Generate Real Family Data
    
    static func generateKocherlakotaFamily() -> (people: [Person], relationships: [MockRelationship]) {
        var people: [Person] = []
        var relationships: [MockRelationship] = []
        var personMap: [String: UUID] = [:] // Track IDs by name
        
        // Helper to create person
        func createPerson(name: String, birthYear: Int) -> Person {
            let person = Person(id: UUID(), fullName: name, birthYear: birthYear)
            people.append(person)
            personMap[name] = person.id
            return person
        }
        
        // Helper to link parent-child
        func linkParentChild(parentName: String, childName: String) {
            guard let parentId = personMap[parentName],
                  let childId = personMap[childName] else { return }
            
            relationships.append(MockRelationship(
                id: UUID(),
                personId: childId,
                relatedPersonId: parentId,
                type: .parent
            ))
            relationships.append(MockRelationship(
                id: UUID(),
                personId: parentId,
                relatedPersonId: childId,
                type: .child
            ))
        }
        
        // Helper to link siblings
        func linkSiblings(_ names: [String]) {
            for i in 0..<names.count {
                for j in (i+1)..<names.count {
                    guard let id1 = personMap[names[i]],
                          let id2 = personMap[names[j]] else { continue }
                    
                    relationships.append(MockRelationship(
                        id: UUID(),
                        personId: id1,
                        relatedPersonId: id2,
                        type: .sibling
                    ))
                    relationships.append(MockRelationship(
                        id: UUID(),
                        personId: id2,
                        relatedPersonId: id1,
                        type: .sibling
                    ))
                }
            }
        }
        
        // Helper to link spouses
        func linkSpouse(person1: String, person2: String) {
            guard let id1 = personMap[person1],
                  let id2 = personMap[person2] else { return }
            
            relationships.append(MockRelationship(
                id: UUID(),
                personId: id1,
                relatedPersonId: id2,
                type: .spouse
            ))
            relationships.append(MockRelationship(
                id: UUID(),
                personId: id2,
                relatedPersonId: id1,
                type: .spouse
            ))
        }
        
        // GENERATION I (Root Ancestor)
        _ = createPerson(name: "Subbaayudu", birthYear: 1800)
        
        // GENERATION II
        _ = createPerson(name: "Venkatappaiah", birthYear: 1830)
        linkParentChild(parentName: "Subbaayudu", childName: "Venkatappaiah")
        
        // GENERATION III - Children of Venkatappaiah
        let gen3Names = [
            "Pedasubbarao",
            "Chinnasubbarao", 
            "Narayanmurthy",
            "Kanakamma",
            "Narasamma",
            "Paparowa",
            "Chandramathi",
            "Chelamma (Kamala)"
        ]
        
        for (index, name) in gen3Names.enumerated() {
            let birthYear = 1860 + (index * 3)
            _ = createPerson(name: name, birthYear: birthYear)
            linkParentChild(parentName: "Venkatappaiah", childName: name)
        }
        linkSiblings(gen3Names)
        
        // GENERATION IV - Branch D (Kanakamma's children)
        let kanakammaChildren = [
            ("Parthasarathy", 1890),
            ("Ramakrishna", 1893),
            ("Sarada (Late)", 1896),
            ("Sarojini", 1899),
            ("Shakuntala", 1902),
            ("Anasuya", 1905),
            ("Syamamsundara Rao", 1908),
            ("Satya Prabhakara Rao", 1911),
            ("Ramachandra Venkata Krishnarao", 1914),
            ("Jaganmohan Chakravarthy", 1917),
            ("Sri Hari Rao", 1920),
            ("Sundarasavarao", 1923),
            ("Raghavendra rao", 1926),
            ("Subramanyam", 1929),
            ("Seethadevi", 1932),
            ("Meenakshi", 1935),
            ("Parvathi", 1938)
        ]
        
        for (name, year) in kanakammaChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Kanakamma", childName: name)
        }
        linkSiblings(kanakammaChildren.map { $0.0 })
        
        // GENERATION V - Children of Parthasarathy
        let parthasarathyChildren = [
            ("Sanjiv", 1920),
            ("Chanakya", 1923)
        ]
        for (name, year) in parthasarathyChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Parthasarathy", childName: name)
        }
        linkSiblings(parthasarathyChildren.map { $0.0 })
        
        // GENERATION V - Children of Sarojini (D7)
        let sarojiniChildren = [
            ("Babji", 1930),
            ("Srinivas", 1933),
            ("Satya Vara Prasad alias Chanti", 1936),
            ("n.a.", 1939),
            ("Lakshmi", 1942),
            ("Tayaru", 1945),
            ("Baby", 1948),
            ("Shakila", 1951),
            ("Supraba", 1954),
            ("Susila Rani", 1957),
            ("Puspa Kumari", 1960),
            ("Rama", 1963),
            ("Uma Devi", 1966),
            ("Durgamani Chakravarthy", 1969)
        ]
        for (name, year) in sarojiniChildren {
            if name != "n.a." {
                _ = createPerson(name: name, birthYear: year)
                linkParentChild(parentName: "Sarojini", childName: name)
            }
        }
        linkSiblings(sarojiniChildren.filter { $0.0 != "n.a." }.map { $0.0 })
        
        // GENERATION V - Children of Shakuntala (D8)
        let shakuntalaChildren = [
            ("Nagendra Pratap", 1935),
            ("Ravindra Kashyap", 1938)
        ]
        for (name, year) in shakuntalaChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Shakuntala", childName: name)
        }
        linkSiblings(shakuntalaChildren.map { $0.0 })
        
        // GENERATION V - Children of Anasuya (D9)
        let anasuyaChildren = [
            ("Pavani", 1940),
            ("Vijay", 1943)
        ]
        for (name, year) in anasuyaChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Anasuya", childName: name)
        }
        linkSiblings(anasuyaChildren.map { $0.0 })
        
        // GENERATION V - Children of Syamamsundara Rao (D8)
        let syamamChildren = [
            ("Ajay", 1945),
            ("Lavanya", 1948),
            ("Karunya", 1951),
            ("Saranya", 1954)
        ]
        for (name, year) in syamamChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Syamamsundara Rao", childName: name)
        }
        linkSiblings(syamamChildren.map { $0.0 })
        
        // GENERATION VI - Children of Subbarao (D18)
        let subbaraoChildren = [
            ("Lakshmi Suhasini", 1965),
            ("Sashi Kanth", 1968),
            ("Srinivasa Chakravarthy", 1971),
            ("Sreelakha", 1974),
            ("Naga Venkata Manikanta Krishna Chaitanya", 1977),
            ("Nidhi Kashyap", 1980),
            ("Movva Neupama", 1983),
            ("Abhishek", 1986),
            ("Karuna", 1989),
            ("Varun", 1992),
            ("Chaitri", 1995),
            ("Devika", 1998),
            ("Krishna Sahithi", 2001),
            ("Lakshman", 2004)
        ]
        
        // Find or create Subbarao first
        if personMap["Subbarao"] == nil {
            _ = createPerson(name: "Subbarao", birthYear: 1935)
        }
        
        for (name, year) in subbaraoChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Subbarao", childName: name)
        }
        linkSiblings(subbaraoChildren.map { $0.0 })
        
        // Add some spouses for realism
        _ = createPerson(name: "Lakshmi Devi", birthYear: 1833)
        linkSpouse(person1: "Venkatappaiah", person2: "Lakshmi Devi")
        
        _ = createPerson(name: "Rama Devi", birthYear: 1893)
        linkSpouse(person1: "Parthasarathy", person2: "Rama Devi")
        
        _ = createPerson(name: "Sujana", birthYear: 1973)
        linkSpouse(person1: "Srinivasa Chakravarthy", person2: "Sujana")
        
        // Add children for Srinivasa Chakravarthy (example - you/your family)
        let srinivasaChildren = [
            ("Sloka Kocherlakota", 2005),
            ("Rishi Kocherlakota", 2008)
        ]
        for (name, year) in srinivasaChildren {
            _ = createPerson(name: name, birthYear: year)
            linkParentChild(parentName: "Srinivasa Chakravarthy", childName: name)
            linkParentChild(parentName: "Sujana", childName: name)
        }
        linkSiblings(srinivasaChildren.map { $0.0 })
        
        print("✅ Generated \(people.count) people from real Kocherlakota family tree")
        print("✅ Generated \(relationships.count) relationships")
        
        return (people, relationships)
    }
}
