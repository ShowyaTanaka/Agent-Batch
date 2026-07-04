//
//  CatalogSharedViews.swift
//  Agent_Batch
//
//

import SwiftUI

struct EditableFieldContainerModifier: ViewModifier {
    let isEditing: Bool

    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .textBackgroundColor))
            )
            .overlay(alignment: .center) {
                if isEditing {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 2)
                }
            }
    }
}

extension View {
    func editableFieldContainer(isEditing: Bool) -> some View {
        modifier(EditableFieldContainerModifier(isEditing: isEditing))
    }
}

struct ReadOnlyFieldView: View {
    let text: String
    let placeholder: String

    var body: some View {
        Text(displayText)
            .foregroundStyle(text.isEmpty ? .secondary : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            }
    }

    private var displayText: String {
        text.isEmpty ? placeholder : text
    }
}

struct ReadOnlyEditorView: View {
    let text: String
    let placeholder: String
    let minHeight: CGFloat

    var body: some View {
        ScrollView {
            Text(displayText)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .padding(8)
        }
        .frame(minHeight: minHeight)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        }
    }

    private var displayText: String {
        text.isEmpty ? placeholder : text
    }
}

struct ListActionBar: View {
    let onAdd: () -> Void
    let onDelete: () -> Void
    let canDelete: Bool

    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .frame(width: 28, height: 22)
                }
                .buttonStyle(.plain)

                Divider()
                    .frame(height: 16)

                Button(action: onDelete) {
                    Image(systemName: "minus")
                        .frame(width: 28, height: 22)
                }
                .buttonStyle(.plain)
                .disabled(!canDelete)
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct RelatedItemsSelectionView: View {
    let title: String
    let options: [String]
    @Binding var selectedItems: [String]
    let isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            List {
                ForEach(options, id: \.self) { option in
                    VStack(spacing: 0) {
                        Button {
                            toggleSelection(for: option)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: selectedItems.contains(option) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedItems.contains(option) ? Color.accentColor : .secondary)

                                Text(option)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!isEnabled)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .opacity(isEnabled ? 1 : 0.7)
            .editableFieldContainer(isEditing: isEnabled)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func toggleSelection(for option: String) {
        if selectedItems.contains(option) {
            selectedItems.removeAll { $0 == option }
        } else {
            selectedItems.append(option)
        }
    }
}
