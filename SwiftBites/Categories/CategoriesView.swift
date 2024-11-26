import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query var categories: [Category]
    @State private var query = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Categories")
                .toolbar {
                    if !categories.isEmpty {
                        NavigationLink {
                            CategoryForm()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
        }
    }
    
    private var filteredCategories: [Category] {
        let predicate = #Predicate<Category> {
            $0.name.localizedStandardContains(query)
        }
        let descriptor = FetchDescriptor<Category>(
            predicate: query.isEmpty ? nil : predicate
        )
        
        do {
            let filteredCategories = try context.fetch(descriptor)
            return filteredCategories
        } catch {
            return []
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var content: some View {
        if categories.isEmpty {
            empty
        } else {
            list(for: filteredCategories)
        }
    }
    
    private var empty: some View {
        ContentUnavailableView(
            label: {
                Label("No Categories", systemImage: "list.clipboard")
            },
            description: {
                Text("Categories you add will appear here.")
            },
            actions: {
                NavigationLink {
                    CategoryForm()
                } label: {
                    Text("Add Category")
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
    
    private func list(for categories: [Category]) -> some View {
        ScrollView(.vertical) {
            if categories.isEmpty {
                noResults
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(categories) { category in
                        CategorySection(category: category)
                    }
                }
            }
        }
        .searchable(text: $query)
    }
}
