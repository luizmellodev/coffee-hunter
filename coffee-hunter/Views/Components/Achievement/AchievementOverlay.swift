import SwiftUI

struct AchievementOverlay: View {
    let mission: Mission
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                
                Text("Nova Conquista!")
                    .font(.title2)
                    .bold()
                
                Text(mission.title)
                    .font(.headline)
                
                Text(mission.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("+\(mission.points) pontos")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding()
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .edgesIgnoringSafeArea(.all)
        .transition(.opacity)
    }
}
