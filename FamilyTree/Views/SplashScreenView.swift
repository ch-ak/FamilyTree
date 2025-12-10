import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0.0
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.15, green: 0.25, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles in background
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 10)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Family tree icon with animation
                ZStack {
                    // Outer glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0.5 : 1.0)
                    
                    // Main icon
                    Image(systemName: "tree.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .white.opacity(0.5), radius: 20)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
                
                // Family name with elegant animation
                VStack(spacing: 12) {
                    Text("Kocherlakota")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                    
                    Text("Family Tree")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(8)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                }
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
                
                Spacer()
                
                // Loading progress bar
                VStack(spacing: 16) {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.2))
                            .frame(width: 250, height: 8)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 250 * progress, height: 8)
                            .shadow(color: .white.opacity(0.5), radius: 5)
                    }
                    
                    // Loading text
                    Text("Preparing your family connections...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start icon animation
        withAnimation {
            isAnimating = true
        }
        
        // Simulate loading progress
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if progress < 1.0 {
                withAnimation(.linear(duration: 0.03)) {
                    progress += 0.015
                }
            } else {
                timer.invalidate()
                // Add slight delay before transitioning
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        isActive = false
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
}
