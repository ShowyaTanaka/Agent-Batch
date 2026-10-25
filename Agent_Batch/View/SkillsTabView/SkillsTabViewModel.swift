//
//  SkillsTabViewModel.swift
//  Agent_Batch
//
//

import Foundation

protocol SkillsTabViewModelProtocol: CatalogTabViewModelProtocol where Entity == SkillCatalogEntity {}

final class SkillsTabViewModel: BaseCatalogTabViewModel<SkillCatalogEntity>, SkillsTabViewModelProtocol {
    init(repository: any SkillRepositoryProtocol) {
        super.init(loadEntities: { repository.skillEntities() }, persistEntities: { repository.saveSkillEntities($0) }, loadSelectedEntityID: { repository.skillEntities().first { repository.selectedEntityID(for: $0) != nil }?.id }, persistSelectedEntityID: { repository.saveSelectedEntityID($0, for: $1) })
    }

    override func summaryText(for entity: SkillCatalogEntity) -> String {
        entity.detail
    }

    override func makeNewEntity() -> SkillCatalogEntity {
        SkillCatalogEntity(
            title: "新しいSkill",
            detail: "詳細を入力してください。",
            content: "内容を入力してください。"
        )
    }
}
