module Meals
  class Container
    extend Dry::Container::Mixin

    register(:external_meals_storage) { TheMealDB::Client.new }
  end
end
