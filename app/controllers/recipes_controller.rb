class RecipesController < ActionController::Base
  layout "application"

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
    params.permit :name, :recipe, :description, :image, :components, :published, :instructions
  end
end