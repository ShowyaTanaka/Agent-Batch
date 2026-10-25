//
//  MCPListTabViewModel.swift
//  Agent_Batch
//
//

import Foundation

protocol MCPListTabViewModelProtocol: CatalogTabViewModelProtocol where Entity == MCPCatalogEntity {}

final class MCPListTabViewModel: BaseCatalogTabViewModel<MCPCatalogEntity>, MCPListTabViewModelProtocol {
    init(repository: any MCPRepositoryProtocol) {
        super.init(loadEntities: { repository.mcpEntities() }, persistEntities: { repository.saveMCPEntities($0) }, loadSelectedEntityID: { repository.mcpEntities().first { repository.selectedEntityID(for: $0) != nil }?.id }, persistSelectedEntityID: { repository.saveSelectedEntityID($0, for: $1) })
    }

    override func summaryText(for entity: MCPCatalogEntity) -> String {
        entity.description
    }

    override func makeNewEntity() -> MCPCatalogEntity {
        MCPCatalogEntity(
            title: "新しいMCP",
            description: "概要を入力してください。",
            content: """
            {
            }
            """
        )
    }
}
