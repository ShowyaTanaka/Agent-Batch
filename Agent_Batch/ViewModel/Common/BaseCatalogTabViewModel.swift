import Combine
import SwiftUI

@MainActor
protocol CatalogTabViewModelProtocol: ObservableObject {
    associatedtype Entity: CatalogEntity
    var entities: [Entity] { get }
    var draftEntityBinding: Binding<Entity?> { get }
    var selectedEntityID: UUID? { get }
    var canDeleteSelectedEntity: Bool { get }
    var canEditSelectedEntity: Bool { get }
    var canSaveSelectedEntity: Bool { get }
    var isEditingSelectedEntity: Bool { get }
    func selectEntity(_ id: UUID?)
    func addEntity()
    func deleteSelectedEntity()
    func beginEditingSelectedEntity()
    func onSave()
    func summaryText(for entity: Entity) -> String
}

@MainActor
class BaseCatalogTabViewModel<Entity: CatalogEntity>: ObservableObject, CatalogTabViewModelProtocol {
    private let loadEntities: () -> [Entity]
    private let persistEntities: ([Entity]) -> Void
    private let loadSelectedEntityID: () -> UUID?
    private let persistSelectedEntityID: (UUID?, Entity?) -> Void

    @Published private(set) var entities: [Entity]
    @Published private(set) var selectedEntityID: UUID?
    @Published private var draftEntitiesByID: [UUID: Entity] = [:]
    @Published private var pendingNewEntityIDs: Set<UUID> = []
    @Published private var editingEntityIDs: Set<UUID> = []

    init(loadEntities: @escaping () -> [Entity], persistEntities: @escaping ([Entity]) -> Void, loadSelectedEntityID: @escaping () -> UUID?, persistSelectedEntityID: @escaping (UUID?, Entity?) -> Void) {
        self.loadEntities = loadEntities
        self.persistEntities = persistEntities
        self.loadSelectedEntityID = loadSelectedEntityID
        self.persistSelectedEntityID = persistSelectedEntityID
        self.entities = loadEntities()
        self.selectedEntityID = loadSelectedEntityID()
    }

    var draftEntityBinding: Binding<Entity?> {
        Binding(get: {
            guard let selectedID = self.selectedEntityID else { return nil }
            return self.draftEntitiesByID[selectedID] ?? self.entities.first { $0.id == selectedID }
        }, set: { updatedEntity in
            guard let updatedEntity else { return }
            self.draftEntitiesByID[updatedEntity.id] = updatedEntity
            if let index = self.entities.firstIndex(where: { $0.id == updatedEntity.id }) { self.entities[index] = updatedEntity }
        })
    }

    func selectEntity(_ id: UUID?) { guard selectedEntityID != id else { return }; setSelectedEntityID(id) }
    var canDeleteSelectedEntity: Bool { selectedEntityID.map { id in entities.contains { $0.id == id } } ?? false }
    var canEditSelectedEntity: Bool { selectedEntityID != nil && !isEditingSelectedEntity }
    var canSaveSelectedEntity: Bool { isEditingSelectedEntity }
    var isEditingSelectedEntity: Bool { selectedEntityID.map { editingEntityIDs.contains($0) } ?? false }

    func addEntity() {
        let entity = makeNewEntity(); entities.append(entity); draftEntitiesByID[entity.id] = entity
        pendingNewEntityIDs.insert(entity.id); editingEntityIDs.insert(entity.id); setSelectedEntityID(entity.id)
    }

    func deleteSelectedEntity() {
        guard let selectedID = selectedEntityID, let index = entities.firstIndex(where: { $0.id == selectedID }) else { return }
        let nextSelection: UUID? = entities.count == 1 ? nil : (index < entities.count - 1 ? entities[index + 1].id : entities[index - 1].id)
        let isPending = pendingNewEntityIDs.contains(selectedID)
        setSelectedEntityID(nextSelection); draftEntitiesByID.removeValue(forKey: selectedID); pendingNewEntityIDs.remove(selectedID); editingEntityIDs.remove(selectedID); entities.remove(at: index)
        if !isPending { var savedEntities = loadEntities(); savedEntities.removeAll { $0.id == selectedID }; persistEntities(savedEntities) }
    }

    func beginEditingSelectedEntity() {
        guard let selectedID = selectedEntityID else { return }
        if draftEntitiesByID[selectedID] == nil, let entity = entities.first(where: { $0.id == selectedID }) { draftEntitiesByID[selectedID] = entity }
        editingEntityIDs.insert(selectedID)
    }

    func onSave() {
        guard let selectedID = selectedEntityID, let draftEntity = draftEntitiesByID[selectedID] else { return }
        var savedEntities = loadEntities()
        if let index = savedEntities.firstIndex(where: { $0.id == selectedID }) { savedEntities[index] = draftEntity } else { savedEntities.append(draftEntity) }
        if let index = entities.firstIndex(where: { $0.id == selectedID }) { entities[index] = draftEntity } else { entities.append(draftEntity) }
        persistEntities(savedEntities); pendingNewEntityIDs.remove(selectedID); editingEntityIDs.remove(selectedID)
    }

    func summaryText(for entity: Entity) -> String { entity.title }
    func makeNewEntity() -> Entity { fatalError("Subclasses must implement makeNewEntity().") }

    private func setSelectedEntityID(_ id: UUID?) {
        selectedEntityID = id
        persistSelectedEntityID(id, entities.first { $0.id == id })
    }
}
