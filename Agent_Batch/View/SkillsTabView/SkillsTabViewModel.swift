//
//  SkillsTabViewModel.swift
//  Agent_Batch
//
//

import Foundation

protocol SkillsTabViewModelProtocol: CatalogTabViewModelProtocol {}

final class SkillsTabViewModel: BaseCatalogTabViewModel, SkillsTabViewModelProtocol {
    init(userDefaults: any CatalogUserDefaultsStoreProtocol) {
        super.init(tab: .skills, userDefaults: userDefaults)
    }

    override func summaryText(for item: CatalogItem) -> String {
        item.detail
    }

    override func makeNewItem() -> CatalogItem {
        CatalogItem(
            title: "新しいSkill",
            detail: "詳細を入力してください。",
            content: "内容を入力してください。"
        )
    }
}
