require 'recipe.rb'

class Component < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged
  
  serialize :recipe_ids, Array

  def url
    "/components/#{slug}"
  end
  
  def custom_name
    name + " cocktail recipes"
  end

  def edit_url
    "/components/edit/#{id}"
  end
  
  def backup_image_url
    "https://www.filepicker.io/api/file/drOikI0sTqG2xjWn2WSQ/convert?fit=crop&amp;h=861&amp;w=1500&amp"
  end
  
  def published?
    true
  end
  
  def image_with_backup
    if image.present?
      image
    elsif recipes.last.try(:image).try(:present?)
      recipes.last.image
    else
      backup_image_url
    end
  end

  def recipes
    recipe_ids.map { |recipe_id| Recipe.find_by_id(recipe_id) } - ["",nil]
  end
    
  def tagline
    "#{name.titleize} Cocktail Recipes | Tuxedo no.2"
  end
  
  def subtext
    "components/subtext"
  end
  
  def count_for_display
    "#{recipes.count} cocktails"
  end
  
  def nickname
    nick.present? ? nick : name
  end
  
  def has_list
    !list.nil?
  end
  
  def list_for_textarea
    list_for = List.find_by_id(list)
    list_for ? list_for.content_as_markdown : ":[#{name} 100]"
  end
  
  def create_or_update_list(markdown)
    has_list ? update_list(markdown) : create_list(markdown)
  end
  
  def update_list(markdown)
    list_element = List.find(list)
    list_element.update_attributes(content_as_markdown: markdown, component: id)
    list_element.collect_and_save_list_elements
  end
  
  def create_list(markdown)
    list_element = List.new(content_as_markdown: markdown, name: name, component: id)
    list_element.collect_and_save_list_elements
    update_attribute(:list, list_element.id)
  end
  
  def list_elements
    list.nil? ? recipes : List.find(list).elements
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