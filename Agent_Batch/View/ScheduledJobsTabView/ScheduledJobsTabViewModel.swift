//
//  ScheduledJobsTabViewModel.swift
//  Agent_Batch
//
//

import Foundation

protocol ScheduledJobsTabViewModelProtocol: CatalogTabViewModelProtocol where Entity == TaskCatalogEntity {
    var availableSkillTitles: [String] { get }
    var availableMCPTitles: [String] { get }
}

final class ScheduledJobsTabViewModel: BaseCatalogTabViewModel<TaskCatalogEntity>, ScheduledJobsTabViewModelProtocol {
    private let relatedEntityRepository: any MCPRepositoryProtocol & SkillRepositoryProtocol

    init(repository: any TaskRepositoryProtocol & MCPRepositoryProtocol & SkillRepositoryProtocol) {
        self.relatedEntityRepository = repository
        super.init(loadEntities: { repository.taskEntities() }, persistEntities: { repository.saveTaskEntities($0) }, loadSelectedEntityID: { repository.taskEntities().first { repository.selectedEntityID(for: $0) != nil }?.id }, persistSelectedEntityID: { repository.saveSelectedEntityID($0, for: $1) })
    }

    var availableSkillTitles: [String] {
        relatedEntityRepository.skillEntities().map(\.title)
    }

    var availableMCPTitles: [String] {
        relatedEntityRepository.mcpEntities().map(\.title)
    }

    override func summaryText(for entity: TaskCatalogEntity) -> String {
        entity.description
    }

    override func makeNewEntity() -> TaskCatalogEntity {
        TaskCatalogEntity(
            title: "新しい定期実行",
            description: "概要を入力してください。",
            content: "実行するプロンプトを入力してください。"
        )
    }
}
