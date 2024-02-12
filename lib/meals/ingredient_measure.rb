module Meals
  class IngredientMeasure < Dry::Struct
    attribute :ingredient, Types::String
    attribute :measure, Types::String
  end
end
