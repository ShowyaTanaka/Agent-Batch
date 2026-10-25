//
//  SkillRepositoryProtocol.swift
//  Agent_Batch
//

import Foundation

protocol SkillRepositoryProtocol: AnyObject {
    func skillEntities() -> [SkillCatalogEntity]
    func saveSkillEntities(_ entities: [SkillCatalogEntity])
    func selectedEntityID(for entity: SkillCatalogEntity) -> UUID?
    func saveSelectedEntityID(_ id: UUID?, for entity: SkillCatalogEntity?)
}
