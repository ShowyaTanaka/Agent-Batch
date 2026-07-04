//
//  ScheduledJobsTabViewModel.swift
//  Agent_Batch
//
//

import Foundation

protocol ScheduledJobsTabViewModelProtocol: CatalogTabViewModelProtocol {
    var availableSkillTitles: [String] { get }
    var availableMCPTitles: [String] { get }
}

final class ScheduledJobsTabViewModel: BaseCatalogTabViewModel, ScheduledJobsTabViewModelProtocol {
    private let userDefaultsStore: any CatalogUserDefaultsStoreProtocol

    init(userDefaults: any CatalogUserDefaultsStoreProtocol) {
        self.userDefaultsStore = userDefaults
        super.init(tab: .scheduledJobs, userDefaults: userDefaults)
    }

    var availableSkillTitles: [String] {
        userDefaultsStore.items(for: .skills).map(\.title)
    }

    var availableMCPTitles: [String] {
        userDefaultsStore.items(for: .mcpList).map(\.title)
    }

    override func summaryText(for item: CatalogItem) -> String {
        item.description
    }

    override func makeNewItem() -> CatalogItem {
        CatalogItem(
            title: "新しい定期実行",
            description: "概要を入力してください。",
            content: "実行するプロンプトを入力してください。"
        )
    }
}
