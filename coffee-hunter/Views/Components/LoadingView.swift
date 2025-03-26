import SwiftUI

struct LoadingView: View {
    @State private var steamAnimation = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Cup base shadow
                Capsule()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 80, height: 10)
                    .offset(y: 45)
                    .blur(radius: 3)
                
                // Main cup
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.2),
                                Color(red: 0.4, green: 0.25, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Steam animation
                VStack(spacing: -2) {
                    ForEach(0...2, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .blur(radius: 3)
                            .offset(x: steamAnimation ? 5 : -5)
                            .animation(
                                Animation
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                value: steamAnimation
                            )
                    }
                }
                .offset(y: -45)
            }
            
            Text("Brewing your coffee shops...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            steamAnimation = true
        }
    }
}

struct Cup: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw cup shape
        path.addPath(
            Path { p in
                p.move(to: CGPoint(x: rect.minX + 10, y: rect.maxY))
                p.addCurve(
                    to: CGPoint(x: rect.maxX - 10, y: rect.maxY),
                    control1: CGPoint(x: rect.minX + 10, y: rect.maxY),
                    control2: CGPoint(x: rect.maxX - 10, y: rect.maxY)
                )
                p.addCurve(
                    to: CGPoint(x: rect.maxX, y: rect.minY + 20),
                    control1: CGPoint(x: rect.maxX - 5, y: rect.maxY - 20),
                    control2: CGPoint(x: rect.maxX, y: rect.maxY - 40)
                )
                p.addCurve(
                    to: CGPoint(x: rect.minX, y: rect.minY + 20),
                    control1: CGPoint(x: rect.maxX, y: rect.minY + 20),
                    control2: CGPoint(x: rect.minX, y: rect.minY + 20)
                )
                p.addCurve(
                    to: CGPoint(x: rect.minX + 10, y: rect.maxY),
                    control1: CGPoint(x: rect.minX, y: rect.maxY - 40),
                    control2: CGPoint(x: rect.minX + 5, y: rect.maxY - 20)
                )
            }
        )
        
        // Add handle
        path.addPath(
            Path { p in
                p.move(to: CGPoint(x: rect.maxX - 5, y: rect.midY))
                p.addCurve(
                    to: CGPoint(x: rect.maxX + 20, y: rect.midY),
                    control1: CGPoint(x: rect.maxX + 5, y: rect.midY - 20),
                    control2: CGPoint(x: rect.maxX + 20, y: rect.midY - 20)
                )
                p.addCurve(
                    to: CGPoint(x: rect.maxX - 5, y: rect.midY + 30),
                    control1: CGPoint(x: rect.maxX + 20, y: rect.midY + 20),
                    control2: CGPoint(x: rect.maxX + 5, y: rect.midY + 40)
                )
            }
        )
        
        return path
    }
}

struct SteamParticle: View {
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.4))
            .frame(width: 10, height: 10)
            .blur(radius: 2)
            .offset(x: isAnimating ? 10 : -10)
            .opacity(isAnimating ? 0 : 0.7)
            .animation(
                Animation
                    .easeInOut(duration: 2)
                    .delay(delay)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct SteamGroup: View {
    let steamAnimation: Bool
    
    var body: some View {
        ZStack {
            // Multiple steam particles with different delays and positions
            ForEach(0...5, id: \.self) { index in
                SteamParticle(delay: Double(index) * 0.3)
                    .offset(
                        x: CGFloat(index % 2 == 0 ? 10 : -10),
                        y: -CGFloat(index * 15)
                    )
            }
        }
    }
}
