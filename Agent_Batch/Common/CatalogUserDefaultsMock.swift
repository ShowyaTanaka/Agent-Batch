//
//  CatalogUserDefaultsMock.swift
//  Agent_Batch
//
//

import Foundation

protocol CatalogUserDefaultsStoreProtocol: AnyObject {
    func items(for tab: CatalogTab) -> [CatalogItem]
    func saveItems(_ items: [CatalogItem], for tab: CatalogTab)
    func selectedItemID(for tab: CatalogTab) -> UUID?
    func saveSelectedItemID(_ id: UUID?, for tab: CatalogTab)
}

final class CatalogUserDefaultsMock: CatalogUserDefaultsStoreProtocol {
    private var itemsByTab: [CatalogTab: [CatalogItem]] = [
        .mcpList: [
            CatalogItem(
                title: "Filesystem MCP",
                description: "ローカルファイルを参照・更新するためのMCPです。",
                content: """
                {
                  "name": "filesystem",
                  "root": "/workspace"
                }
                """
            ),
            CatalogItem(
                title: "GitHub MCP",
                description: "Issue、PR、リポジトリ情報を扱うMCPです。",
                content: """
                {
                  "name": "github",
                  "owner": "example",
                  "repo": "sample"
                }
                """
            ),
            CatalogItem(
                title: "Slack MCP",
                description: "チャンネル投稿や履歴取得を行うMCPです。",
                content: """
                {
                  "name": "slack",
                  "channel": "#ops"
                }
                """
            )
        ],
        .scheduledJobs: [
            CatalogItem(
                title: "日次レポート",
                description: "毎朝 09:00 に前日の利用状況を集計します。",
                content: "前日のジョブ実行結果を要約し、異常値があれば強調して報告してください。",
                relatedSkills: ["要約生成", "コードレビュー"],
                relatedMCPs: ["Filesystem MCP", "Slack MCP"]
            ),
            CatalogItem(
                title: "週次バックアップ",
                description: "毎週日曜 02:00 にバックアップを実行します。",
                content: "バックアップ対象の差分を確認し、失敗時は原因候補と再実行手順を出力してください。",
                relatedSkills: ["要約生成"],
                relatedMCPs: ["Filesystem MCP", "GitHub MCP"]
            ),
            CatalogItem(
                title: "月次棚卸し",
                description: "毎月末日に不要データを洗い出します。",
                content: "未使用データをカテゴリ別に整理し、削除候補と保持理由を一覧化してください。",
                relatedSkills: ["要約生成", "テスト作成"],
                relatedMCPs: ["Filesystem MCP"]
            )
        ],
        .skills: [
            CatalogItem(
                title: "コードレビュー",
                detail: "PRの差分を解析して懸念点を整理するSkillです。",
                content: "PRの差分を解析して懸念点を整理します。"
            ),
            CatalogItem(
                title: "要約生成",
                detail: "議事録やログを短く再構成するSkillです。",
                content: "議事録やログから要約を生成します。"
            ),
            CatalogItem(
                title: "テスト作成",
                detail: "既存コードに対するテストケースを提案するSkillです。",
                content: "既存コードに対するテストケースを提案します。"
            )
        ]
    ]
    private var selectedIDs: [CatalogTab: UUID] = [:]

    init() {
        for tab in CatalogTab.allCases {
            selectedIDs[tab] = itemsByTab[tab]?.first?.id
        }
    }

    func items(for tab: CatalogTab) -> [CatalogItem] {
        itemsByTab[tab] ?? []
    }

    func saveItems(_ items: [CatalogItem], for tab: CatalogTab) {
        itemsByTab[tab] = items
    }

    func selectedItemID(for tab: CatalogTab) -> UUID? {
        selectedIDs[tab]
    }

    func saveSelectedItemID(_ id: UUID?, for tab: CatalogTab) {
        selectedIDs[tab] = id
    }
}
