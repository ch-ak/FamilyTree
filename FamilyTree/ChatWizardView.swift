import SwiftUI

struct ChatWizardView: View {
    @ObservedObject var viewModel: CleanPersonFormViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                messageBubble(for: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                        .padding(.bottom, 100)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        scrollToBottom(proxy)
                    }
                    .onAppear {
                        scrollToBottom(proxy)
                    }
                }
                
                if viewModel.currentStep == .done {
                    completionView
                } else {
                    inputView
                }
            }
        }
        .overlay(alignment: .top) {
            if let status = viewModel.statusMessage {
                statusBanner(status)
            }
        }
    }

    private var inputView: some View {
        HStack(spacing: 12) {
            if viewModel.awaitingConfirmation {
                // Text-only input for confirmation
                TextField("Type: mother, father, spouse, siblings, children, or 'new'", text: $viewModel.fullName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
            } else {
                // Normal name + year input
                TextField("Full name", text: $viewModel.fullName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                
                TextField("Year", text: $viewModel.birthYear)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 100)
                    .keyboardType(.numberPad)
            }
            
            Button(action: viewModel.submit) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        viewModel.fullName.isEmpty && !viewModel.awaitingConfirmation
                        ? Color.secondary
                        : Color.blue
                    )
            }
            .disabled(viewModel.isSubmitting)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("All Set!")
                .font(.title2.bold())
            
            Text("Switch to the Family Tree tab to view your family tree.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
            
            VStack(spacing: 12) {
                Text("💡 Want to add more families?")
                    .font(.subheadline.bold())
                
                Text("You can add your sister's family, brother's family, or anyone else you know about!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    viewModel.restartWizard()
                } label: {
                    Label("Add Another Family", systemImage: "person.2.badge.plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
    
    private var isConfirmationStep: Bool {
        switch viewModel.currentStep {
        case .confirmMother, .confirmFather, .confirmOtherSiblings:
            return true
        default:
            return false
        }
    }
    
    private var confirmationButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.fullName = "yes"
                viewModel.submit()
            } label: {
                Label("Yes", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                viewModel.fullName = "no"
                viewModel.submit()
            } label: {
                Label("No", systemImage: "xmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func messageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer(minLength: 60)
            }
            
            Text(message.text)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.role == .user
                    ? Color.blue
                    : Color(.systemGray5)
                )
                .foregroundStyle(
                    message.role == .user
                    ? .white
                    : .primary
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            
            if message.role == .system {
                Spacer(minLength: 60)
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: message.role == .user ? .trailing : .leading)
                    .combined(with: .opacity),
                removal: .opacity
            )
        )
    }

    private func statusBanner(_ message: String) -> some View {
        Button {
            viewModel.statusMessage = nil
        } label: {
            HStack {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.red.gradient)
            )
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatWizardView(viewModel: CleanPersonFormViewModel())
}
