import Foundation

struct MCPCatalogEntity: CatalogEntity {
    let id: UUID
    var title: String
    var description: String
    var content: String

    init(id: UUID = UUID(), title: String, description: String = "", content: String) {
        self.id = id; self.title = title; self.description = description; self.content = content
    }
}
