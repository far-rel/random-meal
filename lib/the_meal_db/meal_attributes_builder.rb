module TheMealDB
  class MealAttributesBuilder
    def self.build_meal_attributes(response)
      {
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
            {ingredient: ingredient, measure: measure}
          end
        end.compact
      }
    end
  end
end
