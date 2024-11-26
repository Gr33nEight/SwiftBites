import SwiftUI

struct IngredientForm: View {
    @State var ingredient: Ingredient?
    
    init(ingredient: Ingredient? = nil) {
        self.ingredient = ingredient
        if let ingredient = ingredient {
            _name = .init(initialValue: ingredient.name)
            title = "Edit \(ingredient.name)"
        }else{
            _name = .init(initialValue: "")
            title = "Add Ingredient"
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
            if let ingredient = ingredient {
                Button(
                    role: .destructive,
                    action: {
                        delete(ingredient: ingredient)
                    },
                    label: {
                        Text("Delete Ingredient")
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
    
    private func delete(ingredient: Ingredient) {
        context.delete(ingredient)
        dismiss()
    }
    
    private func save() {
        if let ingredient = ingredient {
            ingredient.name = name
        }else{
            let ingredient = Ingredient(name: name)
            context.insert(ingredient)
        }
        dismiss()
    }
}
