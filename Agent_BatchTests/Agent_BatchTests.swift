//
//  Agent_BatchTests.swift
//  Agent_BatchTests
//

import Testing
import SwiftUI
@testable import Agent_Batch

@MainActor
struct Agent_BatchTests {
    @Test func addingAnItemUpdatesThePublishedListAndSelectsIt() {
        let store = CatalogUserDefaultsMock()
        let viewModel = MCPListTabViewModel(userDefaults: store)
        let initialCount = viewModel.items.count

        viewModel.addItem()

        #expect(viewModel.items.count == initialCount + 1)
        #expect(viewModel.items.last?.title == "新しいMCP")
        #expect(viewModel.canDeleteSelectedItem)
        #expect(viewModel.isEditingSelectedItem)
    }

    @Test func deletingAnUnsavedItemRestoresTheListWithoutPersistingIt() {
        let store = CatalogUserDefaultsMock()
        let viewModel = SkillsTabViewModel(userDefaults: store)
        let initialCount = viewModel.items.count

        viewModel.addItem()
        viewModel.deleteSelectedItem()

        #expect(viewModel.items.count == initialCount)
        #expect(store.items(for: .skills).count == initialCount)
    }

    @Test func deletingASavedItemUpdatesBothTheListAndStore() {
        let store = CatalogUserDefaultsMock()
        let viewModel = ScheduledJobsTabViewModel(userDefaults: store)
        let initialCount = viewModel.items.count

        viewModel.deleteSelectedItem()

        #expect(viewModel.items.count == initialCount - 1)
        #expect(store.items(for: .scheduledJobs).count == initialCount - 1)
        #expect(viewModel.canDeleteSelectedItem)
    }

    @Test func twentyAddsAtThreePerSecondKeepSelectionAndDeletionConsistent() async throws {
        let store = CatalogUserDefaultsMock()
        let viewModel = MCPListTabViewModel(userDefaults: store)
        let itemToDelete = viewModel.items[1].id

        for _ in 0..<20 {
            viewModel.addItem()
            try await Task.sleep(nanoseconds: 333_000_000)
        }

        #expect(viewModel.items.count == 23)
        #expect(viewModel.canDeleteSelectedItem)

        viewModel.selectItem(itemToDelete)
        viewModel.deleteSelectedItem()

        #expect(viewModel.items.count == 22)
        #expect(!viewModel.items.contains(where: { $0.id == itemToDelete }))
    }

    @Test func selectingAMiddleItemAfterMultipleAddsDeletesThatExactItem() {
        let store = CatalogUserDefaultsMock()
        let viewModel = MCPListTabViewModel(userDefaults: store)

        viewModel.addItem()
        viewModel.addItem()
        viewModel.addItem()

        let selectedID = viewModel.items[1].id
        viewModel.selectItem(selectedID)
        viewModel.deleteSelectedItem()

        #expect(!viewModel.items.contains(where: { $0.id == selectedID }))
        #expect(viewModel.items.count == 5)
    }
}
