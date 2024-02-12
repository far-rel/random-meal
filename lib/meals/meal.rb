module Meals
  class Meal < Dry::Struct
    attribute :id, Types::Coercible::Integer
    attribute :name, Types::String
    attribute :thumbnail, Types::String
    attribute :category, Types::String
    attribute :instructions, Types::String
    attribute :ingredients, Types::Array.of(IngredientMeasure)

    def self.from_api_response(response)
      attributes = {
        id: response["idMeal"],
        name: response["strMeal"],
        thumbnail: response["strMealThumb"],
        category: response["strCategory"],
        instructions: response["strInstructions"],
        ingredients: response.keys.grep(/^strIngredient\d+$/).map do |ingredient_key|
          measure_key = ingredient_key.gsub("Ingredient", "Measure")
          ingredient = response[ingredient_key]
          measure = response[measure_key]
          if ingredient.nil? || ingredient.empty?
            nil
          else
            IngredientMeasure.new(ingredient: ingredient, measure: measure)
          end
        end.compact
      }
      new(attributes)
    end
  end
end
