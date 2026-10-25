import Foundation

struct SkillCatalogEntity: CatalogEntity {
    let id: UUID
    var title: String
    var detail: String
    var content: String

    init(id: UUID = UUID(), title: String, detail: String = "", content: String) {
        self.id = id; self.title = title; self.detail = detail; self.content = content
    }
}
