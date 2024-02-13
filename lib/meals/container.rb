module Meals
  class Container
    extend Dry::Container::Mixin

    register(:external_meals_storage) { TheMealDB::Client.new }
    register(:build_meal_attributes) do |response|
      TheMealDB::MealAttributesBuilder.build_meal_attributes(response)
    end
  end
end
