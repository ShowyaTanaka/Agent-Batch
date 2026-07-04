//
//  SkillsTabView.swift
//  Agent_Batch
//
//

import SwiftUI

struct SkillsTabView<ViewModel: SkillsTabViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(viewModel.items, selection: viewModel.selectionBinding) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text(viewModel.summaryText(for: item))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle(CatalogTab.skills.rawValue)

                Divider()

                ListActionBar(
                    onAdd: viewModel.addItem,
                    onDelete: viewModel.deleteSelectedItem,
                    canDelete: viewModel.canDeleteSelectedItem
                )
            }
        } detail: {
            SkillsDetailView(
                item: viewModel.draftItemBinding,
                isEditing: viewModel.isEditingSelectedItem,
                canEdit: viewModel.canEditSelectedItem,
                canSave: viewModel.canSaveSelectedItem,
                onEdit: viewModel.beginEditingSelectedItem,
                onSave: viewModel.saveSelectedItem
            )
        }
    }
}

private struct SkillsDetailView: View {
    @Binding var item: CatalogItem?
    let isEditing: Bool
    let canEdit: Bool
    let canSave: Bool
    let onEdit: () -> Void
    let onSave: () -> Void

    var body: some View {
        if let itemBinding = Binding($item) {
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
                            TextField("タイトルを入力", text: itemBinding.title)
                                .textFieldStyle(.plain)
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyFieldView(text: itemBinding.wrappedValue.title, placeholder: "タイトルを入力")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("詳細")
                            .font(.headline)
                        if isEditing {
                            TextField("詳細を入力", text: itemBinding.detail)
                                .textFieldStyle(.plain)
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyFieldView(text: itemBinding.wrappedValue.detail, placeholder: "詳細を入力")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容")
                            .font(.headline)
                        if isEditing {
                            TextEditor(text: itemBinding.content)
                                .font(.body)
                                .padding(8)
                                .frame(minHeight: 240)
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyEditorView(
                                text: itemBinding.wrappedValue.content,
                                placeholder: "内容を入力",
                                minHeight: 240
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(24)
            }
        } else {
            ContentUnavailableView("項目を選択してください", systemImage: "sidebar.left")
        }
    }
}
