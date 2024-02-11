require "test_helper"

class RequestRandomMealTest < ActionDispatch::IntegrationTest
  def test_request_random_meal
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(body: api_response.to_json)

    get "/random"

    assert_response :success
    assert_select "h1", "Test Meal"
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
