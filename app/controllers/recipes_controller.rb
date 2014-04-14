class RecipesController < ApplicationController
  def show
    @recipe = Recipe.find(params[:id])
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
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
    params.require(:recipe).permit(:name, :recipe, :description, :image, :published, :instructions)
  end
end