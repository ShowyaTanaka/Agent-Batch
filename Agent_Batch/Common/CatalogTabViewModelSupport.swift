//
//  CatalogTabViewModelSupport.swift
//  Agent_Batch
//
//

import SwiftUI
import Combine

protocol CatalogTabViewModelProtocol: ObservableObject {
    var items: [CatalogItem] { get }
    var draftItemBinding: Binding<CatalogItem?> { get }
    var selectionBinding: Binding<UUID?> { get }
    var canDeleteSelectedItem: Bool { get }
    var canEditSelectedItem: Bool { get }
    var canSaveSelectedItem: Bool { get }
    var isEditingSelectedItem: Bool { get }

    func addItem()
    func deleteSelectedItem()
    func beginEditingSelectedItem()
    func saveSelectedItem()
    func summaryText(for item: CatalogItem) -> String
}

class BaseCatalogTabViewModel: ObservableObject, CatalogTabViewModelProtocol {
    let tab: CatalogTab
    let userDefaults: any CatalogUserDefaultsStoreProtocol
    @Published private var selectedItemID: UUID?
    @Published private var draftItemsByID: [UUID: CatalogItem] = [:]
    @Published private var pendingNewItemIDs: [UUID] = []
    @Published private var editingItemIDs: [UUID] = []

    init(tab: CatalogTab, userDefaults: any CatalogUserDefaultsStoreProtocol) {
        self.tab = tab
        self.userDefaults = userDefaults
        self.selectedItemID = userDefaults.selectedItemID(for: tab)
        primeDraftIfNeeded(for: self.selectedItemID)
    }

    var items: [CatalogItem] {
        let savedItems = userDefaults.items(for: tab)
        let savedIDs = Set(savedItems.map(\.id))
        let mergedSavedItems = savedItems.map { draftItemsByID[$0.id] ?? $0 }
        let pendingItems: [CatalogItem] = pendingNewItemIDs.compactMap { id in
            guard !savedIDs.contains(id) else { return nil }
            return draftItemsByID[id]
        }
        return mergedSavedItems + pendingItems
    }

    var draftItemBinding: Binding<CatalogItem?> {
        Binding(
            get: {
                guard let selectedID = self.selectedItemID else {
                    return nil
                }
                self.primeDraftIfNeeded(for: selectedID)
                return self.draftItemsByID[selectedID]
            },
            set: { updatedItem in
                guard let updatedItem else { return }
                self.draftItemsByID[updatedItem.id] = updatedItem
            }
        )
    }

    var selectionBinding: Binding<UUID?> {
        Binding(
            get: { self.selectedItemID },
            set: {
                self.selectedItemID = $0
                self.userDefaults.saveSelectedItemID($0, for: self.tab)
                self.primeDraftIfNeeded(for: $0)
            }
        )
    }

    var canDeleteSelectedItem: Bool {
        guard let selectedID = selectedItemID else { return false }
        return items.contains(where: { $0.id == selectedID })
    }

    var canEditSelectedItem: Bool {
        selectedItemID != nil && !isEditingSelectedItem
    }

    var canSaveSelectedItem: Bool {
        isEditingSelectedItem
    }

    var isEditingSelectedItem: Bool {
        guard let selectedID = selectedItemID else { return false }
        return editingItemIDs.contains(selectedID)
    }

    func addItem() {
        let newItem = makeNewItem()
        draftItemsByID[newItem.id] = newItem
        pendingNewItemIDs.append(newItem.id)
        editingItemIDs.append(newItem.id)
        selectedItemID = newItem.id
        userDefaults.saveSelectedItemID(newItem.id, for: tab)
    }

    func deleteSelectedItem() {
        let currentItems = items
        guard
            let selectedID = selectedItemID,
            let index = currentItems.firstIndex(where: { $0.id == selectedID })
        else {
            return
        }

        let nextSelection: UUID?
        if currentItems.count == 1 {
            nextSelection = nil
        } else if index < currentItems.count - 1 {
            nextSelection = currentItems[index + 1].id
        } else {
            nextSelection = currentItems[index - 1].id
        }

        var savedItems = userDefaults.items(for: tab)
        if let savedIndex = savedItems.firstIndex(where: { $0.id == selectedID }) {
            savedItems.remove(at: savedIndex)
            userDefaults.saveItems(savedItems, for: tab)
        }

        draftItemsByID.removeValue(forKey: selectedID)
        pendingNewItemIDs.removeAll { $0 == selectedID }
        editingItemIDs.removeAll { $0 == selectedID }

        selectedItemID = nextSelection
        userDefaults.saveSelectedItemID(nextSelection, for: tab)
        primeDraftIfNeeded(for: nextSelection)
        scheduleViewUpdate()
    }

    func beginEditingSelectedItem() {
        guard let selectedID = selectedItemID else { return }
        primeDraftIfNeeded(for: selectedID)
        guard !editingItemIDs.contains(selectedID) else { return }
        editingItemIDs.append(selectedID)
    }

    func saveSelectedItem() {
        guard
            let selectedID = selectedItemID,
            let draftItem = draftItemsByID[selectedID]
        else {
            return
        }

        var savedItems = userDefaults.items(for: tab)
        if let savedIndex = savedItems.firstIndex(where: { $0.id == selectedID }) {
            savedItems[savedIndex] = draftItem
        } else {
            savedItems.append(draftItem)
        }

        pendingNewItemIDs.removeAll { $0 == selectedID }
        editingItemIDs.removeAll { $0 == selectedID }
        userDefaults.saveItems(savedItems, for: tab)
        scheduleViewUpdate()
    }

    func summaryText(for item: CatalogItem) -> String {
        item.title
    }

    func makeNewItem() -> CatalogItem {
        CatalogItem(title: "新規項目", content: "")
    }

    private func primeDraftIfNeeded(for id: UUID?) {
        guard
            let id,
            draftItemsByID[id] == nil,
            let savedItem = userDefaults.items(for: tab).first(where: { $0.id == id })
        else {
            return
        }

        draftItemsByID[id] = savedItem
    }

    func scheduleViewUpdate() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
