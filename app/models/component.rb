require 'recipe.rb'

class Component < ActiveRecord::Base
  serialize :recipe_ids, Array

  def url
    "/components/#{id}"
  end

  def recipes
    recipe_ids.map { |recipe_id| Recipe.find(recipe_id) }
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end

end