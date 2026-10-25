import Foundation

struct TaskCatalogEntity: CatalogEntity {
    let id: UUID
    var title: String
    var description: String
    var content: String
    var relatedSkills: [String]
    var relatedMCPs: [String]

    init(id: UUID = UUID(), title: String, description: String = "", content: String, relatedSkills: [String] = [], relatedMCPs: [String] = []) {
        self.id = id; self.title = title; self.description = description; self.content = content
        self.relatedSkills = relatedSkills; self.relatedMCPs = relatedMCPs
    }
}
