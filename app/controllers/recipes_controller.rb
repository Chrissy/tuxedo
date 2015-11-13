require 'list.rb'
require 'component.rb'

class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :search]
  layout "application"

  def show
    @recipe = Recipe.friendly.find(params[:id])
    @layout_object = @recipe
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
    recipe.convert_recipe_to_html_and_store
    recipe.make_my_number_last! if params[:make_my_number_last]
    Relationship.touch_all_parents_of(recipe)
    recipe.store_recommends
    redirect_to action: "show", id: recipe.id
  end

  def create
    recipe = Recipe.create(recipe_params)
    recipe.convert_recipe_to_html_and_store
    recipe.store_recommends
    redirect_to action: "show", id: recipe.id
  end

  def delete
    Recipe.find(params[:id]).delete() if user_signed_in?
    redirect_to action: "admin", controller: "lists"
  end

  def all
    @recipes = Recipe.all.map(&:name)
    respond_to do |format|
      format.json {}
    end
  end

  def search
    respond_to do |format|
      format.json {}
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :recipe, :description, :image, :published, :instructions, :never_make_me_tall, :dont_compress_image)
  end
end
