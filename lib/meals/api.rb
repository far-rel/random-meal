module Meals
  class Api
    extend Dry::Monads[:result]
    extend Dry::Monads::Do::All

    # class MealNotFound < StandardError; end

    class << self
      def random_meal
        random_meal = TheMealDB::Client.random_meal

        return failure(:not_found, "Could not find random meal") if random_meal.nil?

        Success(Meal.from_api_response(random_meal))
      end

      def meal(meal_id)
        meal = TheMealDB::Client.meal(meal_id)
        return failure(:not_found, "Could not find meal with id #{meal_id}") if meal.nil?

        Success(Meal.from_api_response(meal))
      end

      def favorite_meal(user_id, meal_id)
        meal = yield meal(meal_id)

        return failure(:already_favorite, "Meal is already favorite") if is_meal_favorite?(user_id, meal_id)

        favorite_meal = FavoriteMeal.new(user_id: user_id, meal_id: meal.id, name: meal.name)

        if favorite_meal.save
          Success(favorite_meal)
        else
          failure(:validation_errors, favorite_meal.errors)
        end
      end

      def unfavorite_meal(user_id, meal_id)
        favorite_meal = FavoriteMeal.find_by(user_id: user_id, meal_id: meal_id)

        return failure(:already_not_favorite, "Meal is already not favorite") if favorite_meal.nil?

        if favorite_meal&.destroy
          Success(favorite_meal)
        else
          failure(:cant_unfavorite, "Can't unfavorite the meal, please try again later")
        end
      end

      def favorite_meals(user_id)
        Success(FavoriteMeal.where(user_id: user_id).order(created_at: :desc))
      end

      def is_meal_favorite?(user_id, meal_id)
        FavoriteMeal.where(user_id: user_id, meal_id: meal_id).exists?
      end

      private

      def failure(code, additional_info)
        Failure({code: code, additional_info: additional_info})
      end
    end
  end
end
