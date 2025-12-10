import SwiftUI

struct WhoAmIView: View {
    @StateObject private var viewModel = WhoAmIViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, year
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search Section
                searchSection
                
                // Results Section
                if viewModel.isSearching {
                    loadingView
                } else if let person = viewModel.foundPerson {
                    ScrollView {
                        personDetailsView(person: person)
                            .padding()
                    }
                } else if viewModel.hasSearched {
                    notFoundView
                } else {
                    emptyStateView
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
                .padding(.top, 20)
            
            Text("Who Am I?")
                .font(.title.bold())
            
            Text("Search for yourself in the family tree")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
    
    private var searchSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                TextField("Full name", text: $viewModel.searchName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                
                TextField("Year", text: $viewModel.searchYear)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 100)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .year)
                
                Button(action: {
                    focusedField = nil
                    Task { await viewModel.searchPerson() }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(viewModel.canSearch ? Color.blue : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(!viewModel.canSearch || viewModel.isSearching)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var notFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("Not Found")
                .font(.title2.bold())
            
            Text("No person found with that name and birth year.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Try the Chat Wizard to add yourself to the family tree!")
                .font(.callout)
                .foregroundStyle(.blue)
                .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue.opacity(0.5))
            
            Text("Find Yourself")
                .font(.title2.bold())
            
            Text("Enter your full name and birth year above to see if you're in the family tree database.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("View all your relationships", systemImage: "person.2.fill")
                Label("See your family connections", systemImage: "link")
                Label("Check your profile details", systemImage: "info.circle")
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(.top, 20)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    private func personDetailsView(person: PersonInfo) -> some View {
        VStack(spacing: 20) {
            // Profile Card
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                Text(person.fullName)
                    .font(.title.bold())
                
                Text("Born: \(person.birthYear)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            
            // Relationships Section
            if !person.parents.isEmpty || !person.siblings.isEmpty || 
               !person.spouses.isEmpty || !person.children.isEmpty {
                
                VStack(spacing: 16) {
                    Text("👨‍👩‍👧‍👦 Family Relationships")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Parents
                    if !person.parents.isEmpty {
                        relationshipCard(
                            title: "Parents",
                            icon: "figure.2.arms.open",
                            people: person.parents,
                            color: .green
                        )
                    }
                    
                    // Spouses
                    if !person.spouses.isEmpty {
                        relationshipCard(
                            title: "Spouse(s)",
                            icon: "heart.fill",
                            people: person.spouses,
                            color: .pink
                        )
                    }
                    
                    // Siblings
                    if !person.siblings.isEmpty {
                        relationshipCard(
                            title: "Siblings",
                            icon: "person.2.fill",
                            people: person.siblings,
                            color: .orange
                        )
                    }
                    
                    // Children
                    if !person.children.isEmpty {
                        relationshipCard(
                            title: "Children",
                            icon: "figure.and.child.holdinghands",
                            people: person.children,
                            color: .purple
                        )
                    }
                }
            } else {
                // No relationships
                VStack(spacing: 12) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    
                    Text("No Relationships Yet")
                        .font(.headline)
                    
                    Text("Use the Chat Wizard to add your family members!")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }
            
            // Stats Card
            statsCard(person: person)
        }
    }
    
    private func relationshipCard(title: String, icon: String, people: [RelatedPerson], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)
            
            ForEach(people, id: \.id) { person in
                HStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.fullName)
                            .font(.body)
                        Text("Born: \(person.birthYear)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func statsCard(person: PersonInfo) -> some View {
        HStack(spacing: 20) {
            statItem(value: person.parents.count, label: "Parents", icon: "figure.2.arms.open")
            Divider()
            statItem(value: person.siblings.count, label: "Siblings", icon: "person.2")
            Divider()
            statItem(value: person.spouses.count, label: "Spouses", icon: "heart")
            Divider()
            statItem(value: person.children.count, label: "Children", icon: "figure.and.child.holdinghands")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.opacity(0.1))
        )
    }
    
    private func statItem(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text("\(value)")
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Models

struct PersonInfo {
    let id: UUID
    let fullName: String
    let birthYear: Int
    let parents: [RelatedPerson]
    let siblings: [RelatedPerson]
    let spouses: [RelatedPerson]
    let children: [RelatedPerson]
}

struct RelatedPerson {
    let id: UUID
    let fullName: String
    let birthYear: Int
}

#Preview {
    WhoAmIView()
}
