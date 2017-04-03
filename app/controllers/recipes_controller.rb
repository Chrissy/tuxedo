require 'list.rb'
require 'component.rb'

class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :search, :index, :letter_index]
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
    previous_image = recipe.image
    recipe.update_attributes(recipe_params)
    recipe.convert_recipe_to_html_and_store
    recipe.make_my_number_last! if params[:make_my_number_last]
    recipe.create_image_sizes if params[:recipe][:image] && params[:recipe][:image] != previous_image
    redirect_to action: "show", id: recipe.id
  end

  def create
    recipe = Recipe.create(recipe_params)
    recipe.convert_recipe_to_html_and_store
    redirect_to action: "show", id: recipe.id
  end

  def delete
    Recipe.find(params[:id]).destroy if user_signed_in?
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

  def index
    @elements = Recipe.all_for_display
  end

  def letter_index
    @elements = Recipe.get_by_letter(params[:letter])
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :recipe, :description, :image, :published, :instructions, :never_make_me_tall, :dont_compress_image)
  end
end
