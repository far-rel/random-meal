require "test_helper"
require "net/http"
require "json"

class ClientTest < ActiveSupport::TestCase
  def setup
    @client = TheMealDB::Client.new
    @meal_id = 12345
    @meal_name = "Test Meal"
  end

  def test_random_meal_returns_meal_hash
    @cache_mock = Minitest::Mock.new
    @cache_mock.expect(:write, nil, ["meal_#{@meal_id}", Hash], expires_in: 1.day)
    @client = TheMealDB::Client.new(cache: @cache_mock)
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/random.php")
      .to_return(body: stub_request_body)

    meal = @client.random_meal

    assert_equal @meal_name, meal["strMeal"]
    assert_equal @meal_id.to_s, meal["idMeal"]
    assert @cache_mock.verify
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
    @cache_mock = Minitest::Mock.new
    @cache_mock.expect(:fetch, meal_hash, ["meal_#{@meal_id}"], expires_in: 1.day)
    @client = TheMealDB::Client.new(cache: @cache_mock)

    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=#{@meal_id}")
      .to_return(body: stub_request_body)

    meal = @client.meal(@meal_id)

    assert_equal @meal_name, meal["strMeal"]
    assert_equal @meal_id.to_s, meal["idMeal"]
    assert @cache_mock.verify
  end

  def test_meal_handles_no_meal_returned
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=#{@meal_id}")
      .to_return(body: {meals: nil}.to_json)

    assert_nil @client.meal(@meal_id)
  end

  def test_meal_handles_api_failure
    stub_request(:get, "https://www.themealdb.com/api/json/v1/1/lookup.php?i=#{@meal_id}")
      .to_return(status: 500)

    assert_raises(TheMealDB::Client::ApiError) { @client.meal(@meal_id) }
  end

  private

  def stub_request_body
    {meals: [meal_hash]}.to_json
  end

  def meal_hash
    {
      "idMeal" => @meal_id.to_s,
      "strMeal" => @meal_name,
      "strMealThumb" => "https://www.themealdb.com/images/media/meals/abc123.jpg",
      "strCategory" => "Test Category",
      "strInstructions" => "Test Instructions",
      "strIngredient1" => "Test Ingredient 1",
      "strMeasure1" => "Test Measure 1"
    }
  end
end
