module TheMealDB
  class Client
    class ApiError < StandardError; end

    class << self
      def random_meal
        response = request("random.php")
        meal = response["meals"].first
        return nil if meal.nil?
        Meal.from_api_response(meal)
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
end
