class IndexesController < ApplicationController

  def home
    @recipes = Recipe.all.sort_by { |recipe| recipe.name }
  end

end