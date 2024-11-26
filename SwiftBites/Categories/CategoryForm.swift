import SwiftUI

struct CategoryForm: View {
    @State var category: Category?
    init(category: Category? = nil) {
        self.category = category
        if let category = category {
            _name = .init(initialValue: category.name)
            title = "Edit \(category.name)"
        }else{
            _name = .init(initialValue: "")
            title = "Add Category"
        }
    }
    
    private let title: String
    @State private var name: String
    @State private var error: Error?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            if let category = category {
                Button(
                    role: .destructive,
                    action: {
                        delete(category: category)
                    },
                    label: {
                        Text("Delete Category")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                )
            }
        }
        .onAppear {
            isNameFocused = true
        }
        .onSubmit {
            save()
        }
        .alert(error: $error)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty)
            }
        }
    }
    
    // MARK: - Data
    
    private func delete(category: Category) {
        context.delete(category)
        dismiss()
    }
    
    private func save() {
        if let category = category {
            category.name = name
        }else{
            let localCategory = Category(name: name)
            context.insert(localCategory)
        }
        dismiss()
    }
}
