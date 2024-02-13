module Meals
  class Meal < Dry::Struct
    attribute :id, Types::Coercible::Integer
    attribute :name, Types::String
    attribute :thumbnail, Types::String
    attribute :category, Types::String
    attribute :instructions, Types::String
    attribute :ingredients, Types::Array.of(IngredientMeasure)
  end
end
