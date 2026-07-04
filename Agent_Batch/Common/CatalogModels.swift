//
//  CatalogModels.swift
//  Agent_Batch
//
//

import Foundation

struct CatalogItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var detail: String
    var content: String
    var relatedSkills: [String]
    var relatedMCPs: [String]

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        detail: String = "",
        content: String,
        relatedSkills: [String] = [],
        relatedMCPs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.detail = detail
        self.content = content
        self.relatedSkills = relatedSkills
        self.relatedMCPs = relatedMCPs
    }
}

enum CatalogTab: String, CaseIterable, Identifiable {
    case mcpList = "MCP一覧"
    case scheduledJobs = "定期実行一覧"
    case skills = "Skill一覧"

    var id: Self { self }
}
