require "test_helper"

class RequestRandomMealTest < ActionDispatch::IntegrationTest
  def setup
    @meal_id = 12345
    @meal_name = "Test Meal"
  end
  def test_request_random_meal
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(body: api_response.to_json)
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=#{@meal_id}")
      .to_return(body: api_response.to_json)

    get "/meals/random"

    follow_redirect!
    assert_response :success
    assert_select "h1", @meal_name
  end

  def request_nonexistent_meal
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(body: nil)

    get "/meals/random"
    assert_response :not_found
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
