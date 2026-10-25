//
//  ScheduledJobsTabView.swift
//  Agent_Batch
//
//

import SwiftUI

struct ScheduledJobsTabView<ViewModel: ScheduledJobsTabViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var listSelection: UUID?

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ListActionBar(
                    onAdd: {
                        viewModel.addEntity()
                        listSelection = viewModel.selectedEntityID
                    },
                    onDelete: {
                        viewModel.deleteSelectedEntity()
                        listSelection = viewModel.selectedEntityID
                    },
                    canDelete: !viewModel.entities.isEmpty && viewModel.canDeleteSelectedEntity
                )

                Divider()

                CatalogSidebarList(
                    entities: viewModel.entities,
                    selection: $listSelection,
                    summaryText: viewModel.summaryText(for:)
                )
                .onAppear {
                    listSelection = viewModel.selectedEntityID
                }
                .onChange(of: listSelection) { _, selectedID in
                    viewModel.selectEntity(selectedID)
                }
                .navigationTitle(CatalogTab.scheduledJobs.rawValue)
            }
            .frame(
                minWidth: 240,
                idealWidth: 280,
                maxWidth: 360,
                maxHeight: .infinity,
                alignment: .topLeading
            )

            ScheduledJobsDetailView(
                entity: viewModel.draftEntityBinding,
                availableSkillTitles: viewModel.availableSkillTitles,
                availableMCPTitles: viewModel.availableMCPTitles,
                isEditing: viewModel.isEditingSelectedEntity,
                canEdit: viewModel.canEditSelectedEntity,
                canSave: viewModel.canSaveSelectedEntity,
                onEdit: viewModel.beginEditingSelectedEntity,
                onSave: {
                    viewModel.onSave()
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ScheduledJobsDetailView: View {
    @Binding var entity: TaskCatalogEntity?
    let availableSkillTitles: [String]
    let availableMCPTitles: [String]
    let isEditing: Bool
    let canEdit: Bool
    let canSave: Bool
    let onEdit: () -> Void
    let onSave: () -> Void

    var body: some View {
        if let entityBinding = Binding($entity) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("詳細")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Spacer()

                        Button("編集", action: onEdit)
                            .disabled(!canEdit)

                        Button("保存", action: onSave)
                            .disabled(!canSave)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("タイトル")
                            .font(.headline)
                        if isEditing {
                            TextField("タイトルを入力", text: entityBinding.title)
                                .textFieldStyle(.plain)
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyFieldView(text: entityBinding.wrappedValue.title, placeholder: "タイトルを入力")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("概要")
                            .font(.headline)
                        if isEditing {
                            TextField("概要を入力", text: entityBinding.description)
                                .textFieldStyle(.plain)
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyFieldView(text: entityBinding.wrappedValue.description, placeholder: "概要を入力")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("プロンプト")
                            .font(.headline)
                        if isEditing {
                            TextEditor(text: entityBinding.content)
                                .font(.body)
                                .padding(8)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 240,
                                    maxHeight: .infinity
                                )
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyEditorView(
                                text: entityBinding.wrappedValue.content,
                                placeholder: "実行するプロンプトを入力してください。",
                                minHeight: 240
                            )
                        }
                    }

                    HStack(alignment: .top, spacing: 16) {
                        RelatedEntitiesSelectionView(
                            title: "利用するSkill",
                            options: availableSkillTitles,
                            selectedEntities: entityBinding.relatedSkills,
                            isEnabled: isEditing
                        )

                        RelatedEntitiesSelectionView(
                            title: "利用するMCP",
                            options: availableMCPTitles,
                            selectedEntities: entityBinding.relatedMCPs,
                            isEnabled: isEditing
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(24)
            }
        } else {
            ContentUnavailableView("項目を選択してください", systemImage: "sidebar.left")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
