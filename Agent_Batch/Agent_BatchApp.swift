//
//  Agent_BatchApp.swift
//  Agent_Batch
//
//

import SwiftUI

@main
struct Agent_BatchApp: App {
    private let repository: CatalogInMemoryRepository
    private let mcpViewModel: MCPListTabViewModel
    private let scheduledViewModel: ScheduledJobsTabViewModel
    private let skillsViewModel: SkillsTabViewModel

    init() {
        repository = CatalogInMemoryRepository()
        mcpViewModel = MCPListTabViewModel(repository: repository)
        scheduledViewModel = ScheduledJobsTabViewModel(repository: repository)
        skillsViewModel = SkillsTabViewModel(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                mcpViewModel: mcpViewModel,
                scheduledViewModel: scheduledViewModel,
                skillsViewModel: skillsViewModel
            )
        }
    }
}
