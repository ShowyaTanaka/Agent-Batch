//
//  CatalogTabViewModelSupport.swift
//  Agent_Batch
//

import SwiftUI
import Combine

@MainActor
protocol CatalogTabViewModelProtocol: ObservableObject {
    var items: [CatalogItem] { get }
    var draftItemBinding: Binding<CatalogItem?> { get }
    var selectedItemID: UUID? { get }
    var canDeleteSelectedItem: Bool { get }
    var canEditSelectedItem: Bool { get }
    var canSaveSelectedItem: Bool { get }
    var isEditingSelectedItem: Bool { get }

    func selectItem(_ id: UUID?)
    func addItem()
    func deleteSelectedItem()
    func beginEditingSelectedItem()
    func saveSelectedItem()
    func summaryText(for item: CatalogItem) -> String
}

@MainActor
class BaseCatalogTabViewModel: ObservableObject, CatalogTabViewModelProtocol {
    let tab: CatalogTab
    let userDefaults: any CatalogUserDefaultsStoreProtocol

    @Published private(set) var items: [CatalogItem]
    @Published private(set) var selectedItemID: UUID?
    @Published private var draftItemsByID: [UUID: CatalogItem] = [:]
    @Published private var pendingNewItemIDs: Set<UUID> = []
    @Published private var editingItemIDs: Set<UUID> = []

    init(tab: CatalogTab, userDefaults: any CatalogUserDefaultsStoreProtocol) {
        self.tab = tab
        self.userDefaults = userDefaults
        self.items = userDefaults.items(for: tab)
        self.selectedItemID = userDefaults.selectedItemID(for: tab)
    }

    var draftItemBinding: Binding<CatalogItem?> {
        Binding(
            get: {
                guard let selectedID = self.selectedItemID else {
                    return nil
                }
                return self.draftItemsByID[selectedID]
                    ?? self.items.first(where: { $0.id == selectedID })
            },
            set: { updatedItem in
                guard let updatedItem else { return }
                self.draftItemsByID[updatedItem.id] = updatedItem

                if let index = self.items.firstIndex(where: { $0.id == updatedItem.id }) {
                    self.items[index] = updatedItem
                }
            }
        )
    }

    func selectItem(_ id: UUID?) {
        guard selectedItemID != id else { return }
        setSelectedItemID(id)
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
        items.append(newItem)
        draftItemsByID[newItem.id] = newItem
        pendingNewItemIDs.insert(newItem.id)
        editingItemIDs.insert(newItem.id)
        setSelectedItemID(newItem.id)
    }

    func deleteSelectedItem() {
        guard
            let selectedID = selectedItemID,
            let index = items.firstIndex(where: { $0.id == selectedID })
        else {
            return
        }


        let nextSelection: UUID?
        if items.count == 1 {
            nextSelection = nil
        } else if index < items.count - 1 {
            nextSelection = items[index + 1].id
        } else {
            nextSelection = items[index - 1].id
        }

        let isPendingNewItem = pendingNewItemIDs.contains(selectedID)

        // Publish the next valid selection before removing the current item.
        setSelectedItemID(nextSelection)
        draftItemsByID.removeValue(forKey: selectedID)
        pendingNewItemIDs.remove(selectedID)
        editingItemIDs.remove(selectedID)
        items.remove(at: index)

        #if DEBUG
        print("[CatalogDelete] tab=\(tab.rawValue) deletedID=\(selectedID) remaining=\(items.count) selectedID=\(String(describing: selectedItemID))")
        #endif

        if !isPendingNewItem {
            var savedItems = userDefaults.items(for: tab)
            savedItems.removeAll { $0.id == selectedID }
            userDefaults.saveItems(savedItems, for: tab)
        }
    }

    func beginEditingSelectedItem() {
        guard let selectedID = selectedItemID else { return }

        if draftItemsByID[selectedID] == nil,
           let item = items.first(where: { $0.id == selectedID }) {
            draftItemsByID[selectedID] = item
        }

        editingItemIDs.insert(selectedID)
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

        if let itemIndex = items.firstIndex(where: { $0.id == selectedID }) {
            items[itemIndex] = draftItem
        } else {
            items.append(draftItem)
        }

        userDefaults.saveItems(savedItems, for: tab)
        pendingNewItemIDs.remove(selectedID)
        editingItemIDs.remove(selectedID)
    }

    func summaryText(for item: CatalogItem) -> String {
        item.title
    }

    func makeNewItem() -> CatalogItem {
        CatalogItem(title: "新規項目", content: "")
    }

    private func setSelectedItemID(_ id: UUID?) {
        selectedItemID = id
        userDefaults.saveSelectedItemID(id, for: tab)
    }
}
