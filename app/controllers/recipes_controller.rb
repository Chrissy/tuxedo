# frozen_string_literal: true

require 'component.rb'

PAGINATION_INTERVAL = 47

class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show search autocomplete index letter_index tag]
  layout 'application'

  def show
    @recipe = Recipe.friendly.find(params[:id])
    first_component = @recipe.components[0]
    @featured_ingredient = first_component.class == Subcomponent ? first_component.component : first_component
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
    redirect_to action: 'show', id: recipe.id
  end

  def create
    recipe = Recipe.create(recipe_params)
    recipe.convert_recipe_to_html_and_store
    redirect_to action: 'show', id: recipe.id
  end

  def delete
    Recipe.find(params[:id]).destroy if user_signed_in?
    redirect_to action: 'admin', controller: 'lists'
  end

  def all
    @recipes = Recipe.all.map(&:name)
    respond_to do |format|
      format.json {}
    end
  end

  def autocomplete
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

  def tag
    @tag = params[:tag].gsub('-', ' ');
    @list_elements = Recipe.tagged_with(@tag).sort_by(&:created_at).reverse
    @pagination_end = PAGINATION_INTERVAL - 1
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :name,
      :recipe,
      :description,
      :image,
      :image2,
      :image3,
      :published,
      :instructions,
      :never_make_me_tall,
      :rating,
      :adapted_from,
      :tag_list,
      :tags_as_text,
      :subtitle
    )
  end
end
