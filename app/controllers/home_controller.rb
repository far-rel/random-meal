class HomeController < ApplicationController
  def index
  end

  def random
    @meal = ::TheMealDB::Client.random_meal
  end
end
