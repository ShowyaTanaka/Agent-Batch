//
//  MCPListTabView.swift
//  Agent_Batch
//
//

import SwiftUI

struct MCPListTabView<ViewModel: MCPListTabViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var listSelection: UUID?

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                ListActionBar(
                    onAdd: {
                        viewModel.addItem()
                        listSelection = viewModel.selectedItemID
                    },
                    onDelete: {
                        viewModel.deleteSelectedItem()
                        listSelection = viewModel.selectedItemID
                    },
                    canDelete: !viewModel.items.isEmpty && viewModel.canDeleteSelectedItem
                )

                Divider()

                CatalogSidebarList(
                    items: viewModel.items,
                    selection: $listSelection,
                    summaryText: viewModel.summaryText(for:)
                )
                .onAppear {
                    listSelection = viewModel.selectedItemID
                }
                .onChange(of: listSelection) { _, selectedID in
                    viewModel.selectItem(selectedID)
                }
                .navigationTitle(CatalogTab.mcpList.rawValue)
            }
            .frame(
                minWidth: 240,
                idealWidth: 280,
                maxWidth: 360,
                maxHeight: .infinity,
                alignment: .topLeading
            )

            MCPListDetailView(
                item: viewModel.draftItemBinding,
                isEditing: viewModel.isEditingSelectedItem,
                canEdit: viewModel.canEditSelectedItem,
                canSave: viewModel.canSaveSelectedItem,
                onEdit: viewModel.beginEditingSelectedItem,
                onSave: viewModel.saveSelectedItem
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MCPListDetailView: View {
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
                        Text("概要")
                            .font(.headline)
                        if isEditing {
                            TextField("概要を入力", text: itemBinding.description)
                                .textFieldStyle(.plain)
                                .editableFieldContainer(isEditing: true)
                        } else {
                            ReadOnlyFieldView(text: itemBinding.wrappedValue.description, placeholder: "概要を入力")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容")
                            .font(.headline)
                        if isEditing {
                            TextEditor(text: itemBinding.content)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
