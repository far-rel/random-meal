require "test_helper"
require "net/http"
require "json"

class ClientTest < ActiveSupport::TestCase
  def setup
    @client = TheMealDB::Client
  end

  def test_random_meal_returns_meal_hash
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(body: stub_request_body)

    meal = @client.random_meal

    assert_equal "Test Meal", meal["strMeal"]
    assert_equal "12345", meal["idMeal"]
  end

  def test_random_meal_handles_no_meal_returned
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(body: {meals: []}.to_json)

    assert_nil @client.random_meal
  end

  def test_random_meal_handles_api_failure
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(status: 500)

    assert_raises(TheMealDB::Client::ApiError) { @client.random_meal }
  end

  def test_meal_returns_meal_hash
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=12345")
      .to_return(body: stub_request_body)

    meal = @client.meal(12345)

    assert_equal "Test Meal", meal["strMeal"]
    assert_equal "12345", meal["idMeal"]
  end

  def test_meal_handles_no_meal_returned
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=12345")
      .to_return(body: {meals: nil}.to_json)

    assert_nil @client.meal(12345)
  end

  def test_meal_handles_api_failure
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=12345")
      .to_return(status: 500)

    assert_raises(TheMealDB::Client::ApiError) { @client.meal(12345) }
  end

  private

  def stub_request_body
    {meals: [
      {
        idMeal: "12345",
        strMeal: "Test Meal",
        strMealThumb: "https://www.themealdb.com/images/media/meals/abc123.jpg",
        strCategory: "Test Category",
        strInstructions: "Test Instructions",
        strIngredient1: "Test Ingredient 1",
        strMeasure1: "Test Measure 1"
      }
    ]}.to_json
  end
end
