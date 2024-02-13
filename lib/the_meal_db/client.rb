module TheMealDB
  class Client
    class ApiError < StandardError; end

    include AutoInject[:cache]

    def random_meal
      response = request("random.php")
      random_meal = response["meals"]&.first
      cache.write("meal_#{random_meal["idMeal"]}", random_meal, expires_in: 1.day) if random_meal
      random_meal
    end

    def meal(id)
      cache.fetch("meal_#{id}", expires_in: 1.day) do
        response = request("lookup.php?i=#{id}")
        response["meals"]&.first
      end
    end

    private

    def request(path)
      uri = URI("https://www.themealdb.com/api/json/v1/1/#{path}")
      response = ::Net::HTTP.get_response(uri)
      raise ApiError, "API request failed with status #{response.code}" unless response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end
end
