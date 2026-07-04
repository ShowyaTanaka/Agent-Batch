import SwiftUI

struct ContentView<
    MCPViewModel: MCPListTabViewModelProtocol,
    ScheduledViewModel: ScheduledJobsTabViewModelProtocol,
    SkillsViewModel: SkillsTabViewModelProtocol
>: View {
    @State private var selectedTab: CatalogTab = .mcpList
    @StateObject private var mcpViewModel: MCPViewModel
    @StateObject private var scheduledViewModel: ScheduledViewModel
    @StateObject private var skillsViewModel: SkillsViewModel

    init(
        mcpViewModel: MCPViewModel,
        scheduledViewModel: ScheduledViewModel,
        skillsViewModel: SkillsViewModel
    ) {
        _mcpViewModel = StateObject(wrappedValue: mcpViewModel)
        _scheduledViewModel = StateObject(wrappedValue: scheduledViewModel)
        _skillsViewModel = StateObject(wrappedValue: skillsViewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("タブ", selection: $selectedTab) {
                ForEach(CatalogTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Group {
                switch selectedTab {
                case .mcpList:
                    MCPListTabView(viewModel: mcpViewModel)
                case .scheduledJobs:
                    ScheduledJobsTabView(viewModel: scheduledViewModel)
                case .skills:
                    SkillsTabView(viewModel: skillsViewModel)
                }
            }
        }
        .frame(minWidth: 900, minHeight: 560)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let userDefaults = CatalogUserDefaultsMock()

        ContentView(
            mcpViewModel: MCPListTabViewModel(userDefaults: userDefaults),
            scheduledViewModel: ScheduledJobsTabViewModel(userDefaults: userDefaults),
            skillsViewModel: SkillsTabViewModel(userDefaults: userDefaults)
        )
    }
}
