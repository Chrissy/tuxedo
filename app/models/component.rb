require 'recipe.rb'

class Component < ActiveRecord::Base
  serialize :recipe_ids, Array

  def url
    "/components/#{id}"
  end

  def edit_url
    "/components/edit/#{id}"
  end

  def delete_url
  end

  def image
    recipes.first.image if recipes.first
  end

  def recipes
    recipe_ids.map { |recipe_id| Recipe.find_by_id(recipe_id) } - ["",nil]
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
  
  def options_for_select
    List.all.map { |list| [list.name, list.id] }.unshift(["Associated List?",""])
  end

end