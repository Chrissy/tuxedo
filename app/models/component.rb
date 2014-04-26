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

  def self.refresh_all
    Component.all.each do |component|
      component.update_attribute(:recipe_ids, [])
    end
    Recipe.update_all
  end

end