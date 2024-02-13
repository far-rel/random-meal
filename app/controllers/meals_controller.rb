class MealsController < ApplicationController
  before_action :authenticate_user!, only: [:favorite, :unfavorite, :favorites]

  rescue_from TheMealDB::Client::ApiError do |_|
    render file: "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error
  end

  def random
    meals_api.random_meal.either(
      ->(meal) { redirect_to meal_path(meal.id) },
      method(:handle_failure)
    )
  end

  def show
    meals_api.meal(params[:id]).either(
      ->(meal) {
        @meal = meal

        if current_user
          @is_meal_favorite = meals_api.is_meal_favorite?(current_user.id, @meal.id)
        end
      },
      method(:handle_failure)
    )
  end

  def favorite
    meals_api.favorite_meal(current_user.id, params[:id]).either(
      ->(_) { redirect_to meal_path(params[:id]) },
      method(:handle_failure)
    )
  end

  def unfavorite
    meals_api.unfavorite_meal(current_user.id, params[:id]).either(
      ->(_) { redirect_back(fallback_location: meal_path(params[:id])) },
      method(:handle_failure)
    )
  end

  def favorites
    meals_api.favorite_meals(current_user.id).either(
      ->(favorite_meals) { @favorite_meals = favorite_meals },
      method(:handle_failure)
    )
  end

  private

  def handle_failure(failure)
    failures = {
      not_found: ->(_) { render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found }
    }

    default_failure = ->(failure) {
      flash[:alert] = failure[:additional_info]
      redirect_back(fallback_location: root_path)
    }

    failures.fetch(failure[:code], default_failure).call(failure)
  end

  def meals_api
    @meals_api ||= Meals::Api.new
  end
end
