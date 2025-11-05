import SwiftUI

struct LoadingView: View {
    @State private var steamAnimation = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Capsule()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 80, height: 10)
                    .offset(y: 45)
                    .blur(radius: 3)
                
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
