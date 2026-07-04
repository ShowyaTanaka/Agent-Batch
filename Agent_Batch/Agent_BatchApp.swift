//
//  Agent_BatchApp.swift
//  Agent_Batch
//
//

import SwiftUI

@main
struct Agent_BatchApp: App {
    private let userDefaults: CatalogUserDefaultsMock
    private let mcpViewModel: MCPListTabViewModel
    private let scheduledViewModel: ScheduledJobsTabViewModel
    private let skillsViewModel: SkillsTabViewModel

    init() {
        userDefaults = CatalogUserDefaultsMock()
        mcpViewModel = MCPListTabViewModel(userDefaults: userDefaults)
        scheduledViewModel = ScheduledJobsTabViewModel(userDefaults: userDefaults)
        skillsViewModel = SkillsTabViewModel(userDefaults: userDefaults)
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
