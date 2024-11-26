import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query var categories: [Category]
    @State private var query = ""
    
    init() {
        self._categories = Query(filter: #Predicate<Category>{
            ($0.name.localizedStandardContains(query) ||
             query.isEmpty)
        })
    }
    
    
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
    
    // MARK: - Views
    
    @ViewBuilder
    private var content: some View {
        if categories.isEmpty {
            empty
        } else {
            list(for: categories.filter {
                if query.isEmpty {
                    return true
                } else {
                    return $0.name.localizedStandardContains(query)
                }
            })
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
