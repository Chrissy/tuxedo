require 'recipe.rb'
require 'component.rb'

class List < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged
  
  serialize :element_ids, Array
  after_save :tell_recipes_about_me

  def elements
    elements = []
    element_ids.each do |element_pair|
      element_collection = expand_element_pair(element_pair)
      elements << element_collection
    end
    elements.flatten.uniq - ["",nil]
  end
  
  def url
    "/list/#{slug}"
  end
  
  def custom_name
    name + " cocktail recipes"
  end

  def edit_url
    "/list/edit/#{id}"
  end
  
  def self.all_for_display
    List.all.keep_if { |list| list.component.nil? }
  end
  
  def tagline
    "#{name} | Tuxedo no.2"
  end
  
  def subtext
    "components/subtext"
  end

  def count_for_display
    "#{elements.count} components"
  end
  
  def recipes
    element_ids.select{ |pair| pair[0] == "Recipe" }.map{ |pair| Recipe.find_by_name(pair[1])}.compact
  end
  
  def tell_recipes_about_me
    recipes.each do |recipe|
      recipe.list_ids << self.id
      recipe.list_ids = recipe.list_ids.uniq
      recipe.save
    end
  end

  def expand_element_pair(element_pair)
    element_collection = []
    if element_pair[1][/(\bALL\b|\bALPH\b|\bDATE\b|\d+)/]
      element_collection = expand_list_code(element_pair[1])
    else
      element_collection = element_pair[0].singularize.classify.constantize.find_by_name(element_pair[1])
    end
    element_collection
  end

  def expand_list_code(list_code)
    first_word = list_code[/(?:(?!\d+).)*/].strip
    limit_number = list_code[/\d+/].to_i
    sort_by = list_code[/(\bDATE\b)/]
    expanded_list = [] 
    if first_word == "ALL" || first_word == "all"
      expanded_list = create_recipe_list(limit_number, sort_by)
    else
      expanded_list = create_component_list(first_word, sort_by)
    end
    expanded_list
  end

  def create_recipe_list(limit_number, sort_by)
    Recipe.limit(limit_number).order(sort_by.nil? ? "name asc" : "last_updated desc").to_a
  end

  def create_component_list(component_name, sort_by)
    component = Component.find_by_name(component_name)
    return if component.nil?
    if sort_by.nil?
      component.recipes.sort_by!(&:name)
    else 
      component.recipes.sort { |a,b| a.last_updated <=> b.last_updated }
    end
  end
  
  def backup_image_url
    "https://www.filepicker.io/api/file/drOikI0sTqG2xjWn2WSQ/convert?fit=crop&amp;h=861&amp;w=1500&amp"
  end
  
  def image_with_backup
    if image.present?
      image
    elsif elements.last && elements.last.image.present?
      elements.last.image
    else
      backup_image_url
    end
  end

  def home?
    name == "Home" || name == "home"
  end
  
  def header_element
    home? ? elements.first : self
  end

  def collect_and_save_list_elements
    elements = []
    content_as_markdown.gsub(/(\=|\:|\#)\[(.*?)\]/) do |*|
      case $1
        when ":" 
          elements.push([Component.to_s, $2])
        when "#" 
          elements.push([List.to_s, $2])
        when "=" 
          elements.push([Recipe.to_s, $2])
      end
    end
    self.update_attribute(:element_ids, elements)
  end
end