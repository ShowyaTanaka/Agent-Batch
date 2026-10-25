import Foundation

protocol CatalogEntity: Identifiable, Hashable where ID == UUID {
    var title: String { get set }
}

enum CatalogTab: String, CaseIterable, Identifiable {
    case mcpList = "MCP一覧"
    case scheduledJobs = "定期実行一覧"
    case skills = "Skill一覧"

    var id: Self { self }
}
