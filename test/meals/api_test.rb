require "test_helper"

class ApiTest < ActiveSupport::TestCase
  def setup
    @meal_id = 12345
    @meal_name = "Test Meal"
    @meals_api = ::Meals::Api.new
  end

  def test_random_meal_returns_meal_object
    mock_random_meal(api_response)

    result = @meals_api.random_meal

    assert result.success?
    assert_equal @meal_id, result.value!.id
    assert_equal @meal_name, result.value!.name
  end

  def test_random_meal_handles_no_meal_returned
    mock_random_meal(nil)

    result = @meals_api.random_meal

    assert_not result.success?
    assert_equal :not_found, result.failure[:code]
  end

  def test_meal_returns_meal_object
    mock_meal(api_response)

    result = @meals_api.meal(@meal_id)

    assert result.success?
    assert_equal @meal_id, result.value!.id
    assert_equal @meal_name, result.value!.name
  end

  def test_meal_handles_no_meal_returned
    mock_meal(nil)

    result = @meals_api.meal(@meal_id)

    assert_not result.success?
    assert_equal :not_found, result.failure[:code]
  end

  def test_favorite_meal_creates_favorite_meal
    user = users(:test)
    mock_meal(api_response)

    result = @meals_api.favorite_meal(user.id, @meal_id)

    assert result.success?
    assert_equal 1, Meals::FavoriteMeal.where(meal_id: @meal_id, user_id: user.id).count
  end

  def test_favorite_meal_handles_already_favorite
    user = users(:test)
    mock_meal(api_response)
    Meals::FavoriteMeal.create(meal_id: @meal_id, user_id: user.id, name: @meal_name)

    result = @meals_api.favorite_meal(user.id, @meal_id)

    assert_not result.success?
    assert_equal :already_favorite, result.failure[:code]
  end

  def test_favorite_meal_handles_missing_meal
    user = users(:test)
    mock_meal(nil)

    result = @meals_api.favorite_meal(user.id, @meal_id)

    assert_not result.success?
    assert_equal :not_found, result.failure[:code]
  end

  def test_unfavorite_meal_deletes_favorite_meal
    user = users(:test)
    Meals::FavoriteMeal.create(meal_id: @meal_id, user_id: user.id, name: @meal_name)
    mock_meal(api_response)

    result = @meals_api.unfavorite_meal(user.id, @meal_id)

    assert result.success?
    assert_equal 0, Meals::FavoriteMeal.where(meal_id: @meal_id, user_id: user.id).count
  end

  def test_unfavorite_meal_handles_already_not_favorite
    user = users(:test)
    mock_meal(api_response)

    result = @meals_api.unfavorite_meal(user.id, @meal_id)

    assert_not result.success?
    assert_equal :already_not_favorite, result.failure[:code]
  end

  def test_favorite_meals_returns_favorite_meals
    user = users(:test)
    Meals::FavoriteMeal.create(meal_id: @meal_id, user_id: user.id, name: @meal_name)

    result = @meals_api.favorite_meals(user.id)

    assert result.success?
    assert_equal @meal_id, result.value![0].meal_id
  end

  def test_is_meal_favorite_returns_true_when_favorite
    user = users(:test)
    Meals::FavoriteMeal.create(meal_id: @meal_id, user_id: user.id, name: @meal_name)

    assert @meals_api.is_meal_favorite?(user.id, @meal_id)
  end

  def test_is_meal_favorite_returns_false_when_not_favorite
    user = users(:test)

    assert_not @meals_api.is_meal_favorite?(user.id, @meal_id)
  end

  private

  def api_response
    {
      "idMeal" => @meal_id.to_s,
      "strMeal" => @meal_name,
      "strMealThumb" => "Test Thumbnail",
      "strCategory" => "Test Category",
      "strInstructions" => "Test Instructions",
      "strIngredient1" => "Test Ingredient",
      "strMeasure1" => "Test Measure"
    }
  end

  def mock_random_meal(meal)
    mock_external_meals_storage(:random_meal, meal)
  end

  def mock_meal(meal)
    mock_external_meals_storage(:meal, meal, @meal_id)
  end

  def mock_external_meals_storage(method, meal, *args)
    @mock = Minitest::Mock.new
    @mock.expect(method, meal, args)
    @meals_api = ::Meals::Api.new(external_meals_storage: @mock)
  end
end
