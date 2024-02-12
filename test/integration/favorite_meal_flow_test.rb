require "test_helper"

class FavoriteMealFlowTest < ActionDispatch::IntegrationTest
  def setup
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=12345")
      .to_return(body: api_response.to_json)
  end

  def test_favorite_meal_for_guest_user
    get "/meals/12345"

    assert_response :success
    assert_select "h1", "Test Meal"
    assert_select "[data-test-id=favorite-meal]", false, "Page does not contain Favorite button"
    assert_select "[data-test-id=unfavorite-meal]", false, "Page does not contain Unfavorite button"

    post "/meals/12345/favorite"
    follow_redirect!
    assert_select "h2", "Log in"

    delete "/meals/12345/unfavorite"
    follow_redirect!
    assert_select "h2", "Log in"
  end

  def test_favorite_meal_for_logged_in_user
    user = users(:test)
    sign_in(user)

    get "/meals/12345"

    assert_response :success
    assert_select "h1", "Test Meal"
    assert_select "[data-test-id=favorite-meal]", "Favorite the meal"

    post "/meals/12345/favorite"
    follow_redirect!

    assert_response :success
    assert_select "h1", "Test Meal"
    assert_select "[data-test-id=unfavorite-meal]", "Unfavorite the meal"
    assert_equal 1, Meals::FavoriteMeal.where(user_id: user.id, meal_id: 12345).count

    post "/meals/12345/favorite"
    follow_redirect!
    assert_select "[data-test-id=flash-alert]", "Meal is already favorite"

    delete "/meals/12345/unfavorite"
    follow_redirect!

    assert_response :success
    assert_select "h1", "Test Meal"
    assert_select "[data-test-id=favorite-meal]", "Favorite the meal"
    assert_equal 0, Meals::FavoriteMeal.where(user_id: user.id, meal_id: 12345).count

    delete "/meals/12345/unfavorite"
    follow_redirect!
    assert_select "[data-test-id=flash-alert]", "Meal is already not favorite"
  end

  private

  def api_response
    {
      meals: [
        {
          idMeal: "12345",
          strMeal: "Test Meal",
          strMealThumb: "https://www.themealdb.com/images/media/meals/abc123.jpg",
          strCategory: "Test Category",
          strInstructions: "Test Instructions",
          strIngredient1: "Test Ingredient",
          strMeasure1: "Test Measure"
        }
      ]
    }
  end
end
