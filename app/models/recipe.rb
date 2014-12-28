require 'component.rb'

class Recipe < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged
  
  serialize :component_ids, Array
  serialize :list_ids, Array
  before_save :touch_associated_lists

  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
  end
  
  def recipe_to_html
    convert_recipe_to_html(recipe)
  end

  def recipe_as_html
    (stored_recipe_as_html || recipe_to_html).html_safe
  end

  def description_to_html
    markdown.render(description).html_safe
  end
  
  def backup_image_url
    "https://www.filepicker.io/api/file/drOikI0sTqG2xjWn2WSQ/convert?fit=crop&amp;h=861&amp;w=1500&amp"
  end
  
  def image_with_backup
    image.present? ? image : backup_image_url
  end

  def components
    component_ids.map { |component_id| Component.find_by_id(component_id) }.compact
  end

  def url
    "/#{slug}"
  end
  
  def custom_name
    name + " cocktail recipe"
  end

  def edit_url
    "/edit/#{id}"
  end

  def delete_url
    ""
  end
  
  def make_my_number_last!
    update_attribute(:created_at, Time.now)
  end
  
  def lists
    list_ids.map { |list_id| List.find(list_id) }
  end
    
  def number
    Recipe.where(:published => true).order('created_at ASC').find_index(self)
  end
  
  def self.compile_numbers_based_on_home
    List.find(1).elements.keep_if{|x|x.is_a?(Recipe)}.each do |recipe|
      recipe.update_attribute(:created_at, Time.now)
    end
  end
  
  def tagline
    "#{name} Cocktail | Tuxedo no.2"
  end
  
  def subtext
    "recipes/subtext"
  end

  def update_components
    components.each do |component|
      recipe_ids = component.recipe_ids.push(self.id).uniq
      component.update_attribute(:recipe_ids, recipe_ids)
    end
  end

  def self.update_all
    Recipe.all.each do |recipe|
      recipe.recipe_to_html
      recipe.update_components
    end
  end
  
  def convert_fractions(str)
   str.gsub(/0\.[0-9]*.*?/) do |match|
     case match
     when "0.5" then '½'
     when "0.25" then '¼'
     when "0.75" then '¾'
     when "0.3" then '⅓'
     when "0.6" then '⅔'
     when "0.125" then '⅛'
     else match
     end
   end.html_safe
  end
  
  def wrap_units(md)
    md.gsub(/([0-9])(oz|tsp|tbsp|Tbsp|dash|dashes)(\b)/) do |*|
      "#{$1}<span class='unit'>#{$2}</span>#{$3}"
    end
  end
  
  private
  
  def touch_associated_lists
    lists.each do |list| 
      list.touch
    end  
  end

  def convert_recipe_to_html(md)
    component_list = []
    md.gsub!(/\:\[(.*?)\]/) do |*|
      component = Component.find_or_create_by(name: $1)
      component_list << component.id
      component.link
    end
    self.update_attribute(:component_ids, component_list)
    update_components()
    md.gsub!(/\* ([0-9].*?|fill) +/) do |*|
      modified_md = wrap_units($1)
      "* <span class='amount'>#{convert_fractions(modified_md)}</span> "
    end
    md.gsub!(/\# ?([A-Z].*?)/) do |*|
      "# " << ApplicationController.helpers.swash($1)
    end
    html = markdown.render(md)
    update_attribute(:stored_recipe_as_html, html)
    html
  end
end