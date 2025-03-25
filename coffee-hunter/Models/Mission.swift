import Foundation

struct Mission: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let points: Int
    let completedDate: Date
    
    init(title: String, description: String, points: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.points = points
        self.completedDate = Date()
    }
}