//
//  MCPListTabViewModel.swift
//  Agent_Batch
//
//

import Foundation

protocol MCPListTabViewModelProtocol: CatalogTabViewModelProtocol {}

final class MCPListTabViewModel: BaseCatalogTabViewModel, MCPListTabViewModelProtocol {
    init(userDefaults: any CatalogUserDefaultsStoreProtocol) {
        super.init(tab: .mcpList, userDefaults: userDefaults)
    }

    override func summaryText(for item: CatalogItem) -> String {
        item.description
    }

    override func makeNewItem() -> CatalogItem {
        CatalogItem(
            title: "新しいMCP",
            description: "概要を入力してください。",
            content: """
            {
            }
            """
        )
    }
}
