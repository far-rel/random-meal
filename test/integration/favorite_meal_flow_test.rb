require "test_helper"

class FavoriteMealFlowTest < ActionDispatch::IntegrationTest
  def setup
    @meal_id = 12345
    @meal_name = "Test Meal"
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=#{@meal_id}")
      .to_return(body: api_response.to_json)
  end

  def test_favorite_meal_for_guest_user
    get "/meals/#{@meal_id}"

    assert_response :success
    assert_select "h1", @meal_name
    assert_select "[data-test-id=favorite-meal]", false, "Page does not contain Favorite button"
    assert_select "[data-test-id=unfavorite-meal]", false, "Page does not contain Unfavorite button"

    post "/meals/#{@meal_id}/favorite"
    follow_redirect!
    assert_select "h2", "Log in"

    delete "/meals/#{@meal_id}/unfavorite"
    follow_redirect!
    assert_select "h2", "Log in"
  end

  def test_favorite_meal_for_logged_in_user
    user = users(:test)
    sign_in(user)

    get "/meals/#{@meal_id}"

    assert_response :success
    assert_select "h1", @meal_name
    assert_select "[data-test-id=favorite-meal]", "Favorite the meal"

    post "/meals/#{@meal_id}/favorite"
    follow_redirect!

    assert_response :success
    assert_select "h1", @meal_name
    assert_select "[data-test-id=unfavorite-meal]", "Unfavorite the meal"
    assert_equal 1, Meals::FavoriteMeal.where(user_id: user.id, meal_id: @meal_id).count

    post "/meals/#{@meal_id}/favorite"
    follow_redirect!
    assert_select "[data-test-id=flash-alert]", "Meal is already favorite"

    delete "/meals/#{@meal_id}/unfavorite"
    follow_redirect!

    assert_response :success
    assert_select "h1", @meal_name
    assert_select "[data-test-id=favorite-meal]", "Favorite the meal"
    assert_equal 0, Meals::FavoriteMeal.where(user_id: user.id, meal_id: @meal_id).count

    delete "/meals/#{@meal_id}/unfavorite"
    follow_redirect!
    assert_select "[data-test-id=flash-alert]", "Meal is already not favorite"
  end

  private

  def api_response
    {
      meals: [
        {
          idMeal: @meal_id,
          strMeal: @meal_name,
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
