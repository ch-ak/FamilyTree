import SwiftUI

struct FamilyTreeTabView: View {
    @ObservedObject var wizardViewModel: CleanPersonFormViewModel
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.2.wave.2")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                Text("My Family Tree")
                    .font(.title.bold())
                
                Text("This is your personal mini family tree view.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Use the **Full Tree** tab to see all family members\nor **D3 Tree** for interactive visualization.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("My Tree")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    ChatWizardView(viewModel: wizardViewModel)
                        .navigationTitle("Add Family Member")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    showingAddSheet = false
                                }
                            }
                        }
                }
            }
        }
    }
}
