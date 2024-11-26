import Foundation
import SwiftUI

/**
 * This file acts as a mock database for temporary data storage, providing CRUD functionality.
 * It is essential to remove this file before the final project submission.
 */

@Observable
final class Storage {
  enum Error: LocalizedError {
    case ingredientExists
    case categoryExists
    case recipeExists

    var errorDescription: String? {
      switch self {
      case .ingredientExists:
        return "Ingredient with the same name exists"
      case .categoryExists:
        return "Category with the same name exists"
      case .recipeExists:
        return "Recipe with the same name exists"
      }
    }
  }

  init() {}

  private(set) var ingredients: [Ingredient] = []
  private(set) var categories: [Category] = []
  private(set) var recipes: [Recipe] = []

  // MARK: - Categories

  func addCategory(name: String) throws {
    guard categories.contains(where: { $0.name == name }) == false else {
      throw Error.categoryExists
    }
    categories.append(Category(name: name))
  }

  func deleteCategory(id: Category.ID) {
    categories.removeAll(where: { $0.id == id })
    for (index, recipe) in recipes.enumerated() where recipe.category?.id == id {
      recipes[index].category = nil
    }
  }

  func updateCategory(id: Category.ID, name: String) throws {
    guard categories.contains(where: { $0.name == name && $0.id != id }) == false else {
      throw Error.categoryExists
    }
    guard let index = categories.firstIndex(where: { $0.id == id }) else {
      return
    }
    categories[index].name = name
    for (index, recipe) in recipes.enumerated() where recipe.category?.id == id {
      recipes[index].category?.name = name
    }
  }

  // MARK: - Ingredients

  func addIngredient(name: String) throws {
    guard ingredients.contains(where: { $0.name == name }) == false else {
      throw Error.ingredientExists
    }
    ingredients.append(Ingredient(name: name))
  }

  func deleteIngredient(id: Ingredient.ID) {
    ingredients.removeAll(where: { $0.id == id })
  }

  func updateIngredient(id: Ingredient.ID, name: String) throws {
    guard ingredients.contains(where: { $0.name == name && $0.id != id }) == false else {
      throw Error.ingredientExists
    }
    guard let index = ingredients.firstIndex(where: { $0.id == id }) else {
      return
    }
    ingredients[index].name = name
  }

  // MARK: - Recipes

  func addRecipe(
    name: String,
    summary: String,
    category: Category?,
    serving: Int,
    time: Int,
    ingredients: [RecipeIngredient],
    instructions: String,
    imageData: Data?
  ) throws {
    guard recipes.contains(where: { $0.name == name }) == false else {
      throw Error.recipeExists
    }
    let recipe = Recipe(
      name: name,
      summary: summary,
      category: category,
      serving: serving,
      time: time,
      ingredients: ingredients,
      instructions: instructions,
      imageData: imageData
    )
    recipes.append(recipe)
    if let category, let index = categories.firstIndex(where: { $0.id == category.id }) {
      categories[index].recipes.append(recipe)
    }
  }

  func deleteRecipe(id: Recipe.ID) {
    recipes.removeAll(where: { $0.id == id })
    for cIndex in categories.indices {
      categories[cIndex].recipes.removeAll(where: { $0.id == id })
    }
  }

  func updateRecipe(
    id: Recipe.ID,
    name: String,
    summary: String,
    category: Category?,
    serving: Int,
    time: Int,
    ingredients: [RecipeIngredient],
    instructions: String,
    imageData: Data?
  ) throws {
    guard recipes.contains(where: { $0.name == name && $0.id != id }) == false else {
      throw Error.recipeExists
    }
    guard let index = recipes.firstIndex(where: { $0.id == id }) else {
      return
    }
    let recipe = Recipe(
      id: id,
      name: name,
      summary: summary,
      category: category,
      serving: serving,
      time: time,
      ingredients: ingredients,
      instructions: instructions,
      imageData: imageData
    )
    recipes[index] = recipe
    for cIndex in categories.indices {
      categories[cIndex].recipes.removeAll(where: { $0.id == id })
    }
    if let cIndex = categories.firstIndex(where: { $0.id == category?.id }) {
      categories[cIndex].recipes.append(recipe)
    }
  }
}

struct StorageKey: EnvironmentKey {
  static let defaultValue = Storage()
}

extension EnvironmentValues {
  var storage: Storage {
    get { self[StorageKey.self] }
    set { self[StorageKey.self] = newValue }
  }
}
