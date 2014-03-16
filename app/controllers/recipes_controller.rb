class RecipesController < ActionController::Base
  def show
  end

  def edit
  end

  def new
  end

  def create
    Recipe.create(recipe_params)
  end

  private

  def recipe_params
    params.permit(:name, :description)
  end
end