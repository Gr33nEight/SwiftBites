//
//  SDModels.swift
//  SwiftBites
//
//  Created by Natanael Jop on 25/11/2024.
//

import Foundation
import SwiftData

@Model
final class Category: Identifiable, Hashable {
    let id: UUID
    var name: String
    @Relationship(inverse: \Recipe.category)
    var recipes: [Recipe]
    
    init(id: UUID = UUID(), name: String = "", recipes: [Recipe] = []) {
        self.id = id
        self.name = name
        self.recipes = recipes
    }
}

@Model
final class Ingredient: Identifiable, Hashable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
}

@Model
final class RecipeIngredient: Identifiable, Hashable {
    let id: UUID
    var ingredient: Ingredient
    var quantity: String
    
    @Relationship(inverse: \Recipe.ingredients) // Inverse relationship to Recipe
    var recipe: Recipe? // This is a reference back to the Recipe

    init(id: UUID = UUID(), ingredient: Ingredient = Ingredient(), quantity: String = "", recipe: Recipe? = nil) {
        self.id = id
        self.ingredient = ingredient
        self.quantity = quantity
        self.recipe = recipe
    }
}

@Model
final class Recipe: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String
    var summary: String
    
    
    @Relationship var category: Category?
    
    var serving: Int
    var time: Int
    var ingredients: [RecipeIngredient] // List of ingredients
    var instructions: String
    var imageData: Data?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        summary: String = "",
        category: Category? = nil,
        serving: Int = 1,
        time: Int = 5,
        ingredients: [RecipeIngredient] = [],
        instructions: String = "",
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.category = category
        self.serving = serving
        self.time = time
        self.ingredients = ingredients
        self.instructions = instructions
        self.imageData = imageData
    }
}
