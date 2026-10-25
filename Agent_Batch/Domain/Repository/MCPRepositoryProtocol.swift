//
//  MCPRepositoryProtocol.swift
//  Agent_Batch
//

import Foundation

protocol MCPRepositoryProtocol: AnyObject {
    func mcpEntities() -> [MCPCatalogEntity]
    func saveMCPEntities(_ entities: [MCPCatalogEntity])
    func selectedEntityID(for entity: MCPCatalogEntity) -> UUID?
    func saveSelectedEntityID(_ id: UUID?, for entity: MCPCatalogEntity?)
}
