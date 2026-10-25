import Foundation

final class CatalogInMemoryRepository: MCPRepositoryProtocol, TaskRepositoryProtocol, SkillRepositoryProtocol {
    private var mcpCatalogEntities: [MCPCatalogEntity] = [
        MCPCatalogEntity(title: "Filesystem MCP", description: "ローカルファイルを参照・更新するためのMCPです。", content: "{\n  \"name\": \"filesystem\",\n  \"root\": \"/workspace\"\n}"),
        MCPCatalogEntity(title: "GitHub MCP", description: "Issue、PR、リポジトリ情報を扱うMCPです。", content: "{\n  \"name\": \"github\",\n  \"owner\": \"example\",\n  \"repo\": \"sample\"\n}"),
        MCPCatalogEntity(title: "Slack MCP", description: "チャンネル投稿や履歴取得を行うMCPです。", content: "{\n  \"name\": \"slack\",\n  \"channel\": \"#ops\"\n}")
    ]
    private var taskCatalogEntities: [TaskCatalogEntity] = [
        TaskCatalogEntity(title: "日次レポート", description: "毎朝 09:00 に前日の利用状況を集計します。", content: "前日のジョブ実行結果を要約し、異常値があれば強調して報告してください。", relatedSkills: ["要約生成", "コードレビュー"], relatedMCPs: ["Filesystem MCP", "Slack MCP"]),
        TaskCatalogEntity(title: "週次バックアップ", description: "毎週日曜 02:00 にバックアップを実行します。", content: "バックアップ対象の差分を確認し、失敗時は原因候補と再実行手順を出力してください。", relatedSkills: ["要約生成"], relatedMCPs: ["Filesystem MCP", "GitHub MCP"]),
        TaskCatalogEntity(title: "月次棚卸し", description: "毎月末日に不要データを洗い出します。", content: "未使用データをカテゴリ別に整理し、削除候補と保持理由を一覧化してください。", relatedSkills: ["要約生成", "テスト作成"], relatedMCPs: ["Filesystem MCP"])
    ]
    private var skillCatalogEntities: [SkillCatalogEntity] = [
        SkillCatalogEntity(title: "コードレビュー", detail: "PRの差分を解析して懸念点を整理するSkillです。", content: "PRの差分を解析して懸念点を整理します。"),
        SkillCatalogEntity(title: "要約生成", detail: "議事録やログを短く再構成するSkillです。", content: "議事録やログから要約を生成します。"),
        SkillCatalogEntity(title: "テスト作成", detail: "既存コードに対するテストケースを提案するSkillです。", content: "既存コードに対するテストケースを提案します。")
    ]
    private var selectedMCPID: UUID?
    private var selectedTaskID: UUID?
    private var selectedSkillID: UUID?

    init() {
        selectedMCPID = mcpCatalogEntities.first?.id
        selectedTaskID = taskCatalogEntities.first?.id
        selectedSkillID = skillCatalogEntities.first?.id
    }

    func mcpEntities() -> [MCPCatalogEntity] { mcpCatalogEntities }
    func saveMCPEntities(_ entities: [MCPCatalogEntity]) { mcpCatalogEntities = entities }
    func taskEntities() -> [TaskCatalogEntity] { taskCatalogEntities }
    func saveTaskEntities(_ entities: [TaskCatalogEntity]) { taskCatalogEntities = entities }
    func skillEntities() -> [SkillCatalogEntity] { skillCatalogEntities }
    func saveSkillEntities(_ entities: [SkillCatalogEntity]) { skillCatalogEntities = entities }
    func selectedEntityID(for entity: MCPCatalogEntity) -> UUID? { selectedMCPID == entity.id ? entity.id : nil }
    func saveSelectedEntityID(_ id: UUID?, for entity: MCPCatalogEntity?) { selectedMCPID = id == entity?.id ? id : nil }
    func selectedEntityID(for entity: TaskCatalogEntity) -> UUID? { selectedTaskID == entity.id ? entity.id : nil }
    func saveSelectedEntityID(_ id: UUID?, for entity: TaskCatalogEntity?) { selectedTaskID = id == entity?.id ? id : nil }
    func selectedEntityID(for entity: SkillCatalogEntity) -> UUID? { selectedSkillID == entity.id ? entity.id : nil }
    func saveSelectedEntityID(_ id: UUID?, for entity: SkillCatalogEntity?) { selectedSkillID = id == entity?.id ? id : nil }
}
