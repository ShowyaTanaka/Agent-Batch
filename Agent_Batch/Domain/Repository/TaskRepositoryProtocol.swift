//
//  TaskRepositoryProtocol.swift
//  Agent_Batch
//

import Foundation

protocol TaskRepositoryProtocol: AnyObject {
    func taskEntities() -> [TaskCatalogEntity]
    func saveTaskEntities(_ entities: [TaskCatalogEntity])
    func selectedEntityID(for entity: TaskCatalogEntity) -> UUID?
    func saveSelectedEntityID(_ id: UUID?, for entity: TaskCatalogEntity?)
}
