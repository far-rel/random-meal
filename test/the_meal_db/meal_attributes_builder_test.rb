require "test_helper"

class MealAttributesBuilderTest < ActiveSupport::TestCase
  def test_meal_from_api_response_creates_correct_meal
    meal = TheMealDB::MealAttributesBuilder.build_meal_attributes(api_response)

    assert_equal api_response["idMeal"], meal[:id]
    assert_equal api_response["strMeal"], meal[:name]
    assert_equal api_response["strMealThumb"], meal[:thumbnail]
    assert_equal api_response["strCategory"], meal[:category]
    assert_equal api_response["strInstructions"], meal[:instructions]
    assert_equal api_response["strIngredient1"], meal[:ingredients].first[:ingredient]
    assert_equal api_response["strMeasure1"], meal[:ingredients].first[:measure]
  end

  def test_meal_from_api_response_handles_missing_ingredients
    response = api_response.except("strIngredient1")

    meal = TheMealDB::MealAttributesBuilder.build_meal_attributes(response)

    assert_empty meal[:ingredients]
  end

  private

  def api_response
    {
      "idMeal" => "12345",
      "strMeal" => "Test Meal",
      "strMealThumb" => "Test Thumbnail",
      "strCategory" => "Test Category",
      "strInstructions" => "Test Instructions",
      "strIngredient1" => "Test Ingredient",
      "strMeasure1" => "Test Measure"
    }
  end
end
