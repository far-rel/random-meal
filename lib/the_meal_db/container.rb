module TheMealDB
  class Container
    extend Dry::Container::Mixin

    register(:cache) { Rails.cache }
  end
end
