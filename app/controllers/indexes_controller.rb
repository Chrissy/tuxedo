class IndexesController < ApplicationController

  def home
    @recipes = Recipe.all
  end

end