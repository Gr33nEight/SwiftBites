import SwiftUI
import SwiftData

struct RecipesView: View {
    @Query var recipes: [Recipe]
    @State private var query = ""
    @State private var sortOrder = SortDescriptor(\Recipe.name)
    @Environment(\.modelContext) private var context
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Recipes")
                .toolbar {
                    if !recipes.isEmpty {
                        sortOptions
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                RecipeForm()
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                        }
                    }
                }
        }
    }
    
    private var filteredRecipes: [Recipe] {
        let predicate = #Predicate<Recipe> {
            $0.name.localizedStandardContains(query)
        }
        let descriptor = FetchDescriptor<Recipe>(
            predicate: query.isEmpty ? nil : predicate
        )
        
        do {
            let filteredRecipes = try context.fetch(descriptor)
            return filteredRecipes.sorted(using: sortOrder)
        } catch {
            return []
        }
    }
    
    // MARK: - Views
    
    @ToolbarContentBuilder
    var sortOptions: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort", selection: $sortOrder) {
                    Text("Name")
                        .tag(SortDescriptor(\Recipe.name))
                    
                    Text("Serving (low to high)")
                        .tag(SortDescriptor(\Recipe.serving, order: .forward))
                    
                    Text("Serving (high to low)")
                        .tag(SortDescriptor(\Recipe.serving, order: .reverse))
                    
                    Text("Time (short to long)")
                        .tag(SortDescriptor(\Recipe.time, order: .forward))
                    
                    Text("Time (long to short)")
                        .tag(SortDescriptor(\Recipe.time, order: .reverse))
                }
            }
            .pickerStyle(.inline)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if recipes.isEmpty {
            empty
        } else {
            list(for: filteredRecipes)
        }
    }
    
    var empty: some View {
        ContentUnavailableView(
            label: {
                Label("No Recipes", systemImage: "list.clipboard")
            },
            description: {
                Text("Recipes you add will appear here.")
            },
            actions: {
                NavigationLink {
                    RecipeForm()
                } label: {
                    Text("Add Recipe")
                }
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.borderedProminent)
            }
        )
    }
    
    private var noResults: some View {
        ContentUnavailableView(
            label: {
                Text("Couldn't find \"\(query)\"")
            }
        )
    }
    
    private func list(for recipes: [Recipe]) -> some View {
        ScrollView(.vertical) {
            if recipes.isEmpty {
                noResults
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(recipes, content: RecipeCell.init)
                }
            }
        }
        .searchable(text: $query)
    }
}
