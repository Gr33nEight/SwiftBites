import SwiftUI
import PhotosUI
import Foundation
import SwiftData

struct RecipeForm: View {
    @State var recipe: Recipe?
    init(recipe: Recipe? = nil) {
        self.recipe = recipe
        if let recipe = recipe {
            title = "Edit \(recipe.name)"
            _name = .init(initialValue: recipe.name)
            _summary = .init(initialValue: recipe.summary)
            _serving = .init(initialValue: recipe.serving)
            _time = .init(initialValue: recipe.time)
            _instructions = .init(initialValue: recipe.instructions)
            _ingredients = .init(initialValue: recipe.ingredients)
            _categoryId = .init(initialValue: recipe.category?.id)
            _imageData = .init(initialValue: recipe.imageData)
        } else {
            title = "Add Recipe"
            _name = .init(initialValue: "")
            _summary = .init(initialValue: "")
            _serving = .init(initialValue: 1)
            _time = .init(initialValue: 5)
            _instructions = .init(initialValue: "")
            _ingredients = .init(initialValue: [])
        }
    }
    
    private let title: String
    @State private var name: String
    @State private var summary: String
    @State private var serving: Int
    @State private var time: Int
    @State private var instructions: String
    @State private var categoryId: Category.ID?
    @State private var ingredients: [RecipeIngredient]
    @State private var imageItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isIngredientsPickerPresented =  false
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var categories: [Category]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            Form {
                imageSection(width: geometry.size.width)
                nameSection
                summarySection
                categorySection
                servingAndTimeSection
                ingredientsSection
                instructionsSection
                deleteButton
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(error: $error)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty || instructions.isEmpty)
            }
        }
        .onChange(of: imageItem) { _, _ in
            Task {
                self.imageData = try? await imageItem?.loadTransferable(type: Data.self)
            }
        }
        .sheet(isPresented: $isIngredientsPickerPresented, content: ingredientPicker)
    }
    
    // MARK: - Views
    
    private func ingredientPicker() -> some View {
        IngredientsView { selectedIngredient in
            let recipeIngredient = RecipeIngredient(ingredient: selectedIngredient, quantity: "")
            recipeIngredient.recipe = recipe
            context.insert(recipeIngredient)
            ingredients.append(recipeIngredient)
            print(ingredients)
        }
    }
    
    @ViewBuilder
    private func imageSection(width: CGFloat) -> some View {
        Section {
            imagePicker(width: width)
            removeImage
        }
    }
    
    @ViewBuilder
    private func imagePicker(width: CGFloat) -> some View {
        PhotosPicker(selection: $imageItem, matching: .images) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: 200, alignment: .center)
            } else {
                Label("Select Image", systemImage: "photo")
            }
        }
    }
    
    @ViewBuilder
    private var removeImage: some View {
        if imageData != nil {
            Button(
                role: .destructive,
                action: {
                    imageData = nil
                },
                label: {
                    Text("Remove Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }
    
    @ViewBuilder
    private var nameSection: some View {
        Section("Name") {
            TextField("Margherita Pizza", text: $name)
        }
    }
    
    @ViewBuilder
    private var summarySection: some View {
        Section("Summary") {
            TextField(
                "Delicious blend of fresh basil, mozzarella, and tomato on a crispy crust.",
                text: $summary,
                axis: .vertical
            )
            .lineLimit(3...5)
        }
    }
    
    @ViewBuilder
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $categoryId) {
                Text("None").tag(nil as Category.ID?)
                ForEach(categories) { category in
                    Text(category.name).tag(category.id as Category.ID?)
                }
            }
        }
    }
    
    @ViewBuilder
    private var servingAndTimeSection: some View {
        Section {
            Stepper("Servings: \(serving)p", value: $serving, in: 1...100)
            Stepper("Time: \(time)m", value: $time, in: 5...300, step: 5)
        }
        .monospacedDigit()
    }
    
    @ViewBuilder
    private var ingredientsSection: some View {
        Section("Ingredients") {
            if ingredients.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("No Ingredients", systemImage: "list.clipboard")
                    },
                    description: {
                        Text("Recipe ingredients will appear here.")
                    },
                    actions: {
                        Button("Add Ingredient") {
                            isIngredientsPickerPresented = true
                        }
                    }
                )
            } else {
                ForEach(ingredients) { ingredient in
                    HStack(alignment: .center) {
                        Text(ingredient.ingredient.name)
                            .bold()
                            .layoutPriority(2)
                        Spacer()
                        TextField("Quantity", text: .init(
                            get: {
                                ingredient.quantity
                            },
                            set: { quantity in
                                if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                                    ingredients[index].quantity = quantity
                                }
                            }
                        ))
                        .layoutPriority(1)
                    }
                }
                .onDelete(perform: deleteIngredients)
                
                Button("Add Ingredient") {
                    isIngredientsPickerPresented = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var instructionsSection: some View {
        Section("Instructions") {
            TextField(
        """
        1. Preheat the oven to 475°F (245°C).
        2. Roll out the dough on a floured surface.
        3. ...
        """,
        text: $instructions,
        axis: .vertical
            )
            .lineLimit(8...12)
        }
    }
    
    @ViewBuilder
    private var deleteButton: some View {
        if recipe != nil {
            Button(
                role: .destructive,
                action: {
                    delete()
                },
                label: {
                    Text("Delete Recipe")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            )
        }
    }
    
    // MARK: - Data
    
    func delete() {
        guard let recipe = recipe else {
            fatalError("Delete unavailable in add mode")
        }
        context.delete(recipe)
        dismiss()
    }
    
    func deleteIngredients(offsets: IndexSet) {
        withAnimation {
            ingredients.remove(atOffsets: offsets)
        }
    }
    
    func save() {
        let selectedCategory = categories.first { $0.id == categoryId }

        if let recipe = recipe {
            recipe.name = name
            recipe.summary = summary
            recipe.category = selectedCategory
            recipe.serving = serving
            recipe.time = time
            recipe.instructions = instructions
            recipe.imageData = imageData

            updateIngredients(for: recipe)

            if let oldCategory = recipe.category, oldCategory != selectedCategory {
                oldCategory.recipes.removeAll { $0.id == recipe.id }
            }
            if let selectedCategory {
                if !selectedCategory.recipes.contains(recipe) {
                    selectedCategory.recipes.append(recipe)
                }
            }
        } else {
            let newRecipe = Recipe(
                name: name,
                summary: summary,
                category: selectedCategory,
                serving: serving,
                time: time,
                ingredients: [],
                instructions: instructions,
                imageData: imageData
            )

            ingredients.forEach { ingredient in
                ingredient.recipe = newRecipe
                context.insert(ingredient)
            }
            newRecipe.ingredients = ingredients

            context.insert(newRecipe)

            if let selectedCategory {
                selectedCategory.recipes.append(newRecipe)
            }
        }

        dismiss()
        print(categories.map({($0.name, $0.recipes.map({($0.name, $0.category?.name)}))}))
    }

    func updateIngredients(for recipe: Recipe) {
        ingredients.forEach { ingredient in
            ingredient.recipe = recipe
            if !recipe.ingredients.contains(where: { $0.id == ingredient.id }) {
                recipe.ingredients.append(ingredient)
            }
            context.insert(ingredient)
        }
    }

}
