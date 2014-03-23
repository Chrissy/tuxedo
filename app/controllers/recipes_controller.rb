class RecipesController < ActionController::Base
  layout "application"

  def show
    @recipe = Recipe.find(params[:id])
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def new
  end

  def update
    recipe = Recipe.find(params[:id])
    recipe.update_attributes(recipe_params)
    recipe.update_attribute(:last_updated, DateTime.now)
    redirect_to action: "show", id: recipe.id
  end

  def create
    recipe = Recipe.create(recipe_params)
    recipe.update_attribute(:last_updated, DateTime.now)
    redirect_to action: "show", id: recipe.id
  end

  private

  def recipe_params
    params.permit :name, :recipe, :description, :image, :components, :published, :instructions
  end
end