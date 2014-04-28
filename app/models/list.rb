require 'recipe.rb'
require 'component.rb'

class List < ActiveRecord::Base
  serialize :element_ids, Array

  def elements
    elements = []
    element_ids.each do |element_pair|
      element_collection = expand_element_pair(element_pair)
      elements << element_collection
    end
    elements.flatten.uniq
  end

  def compile_and_store_list_elements
    elements = collect_list_elements(content_as_markdown)
    self.update_attribute(:element_ids, elements)
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
    if sort_by.nil?
      component.recipes.sort_by!(&:name)
    else 
      component.recipes.sort { |a,b| a.last_updated <=> b.last_updated }
    end
  end

  def image
    elements.first.image || elements[1].image || ""
  end

  def home?
    name == "Home" || name == "home"
  end

  def collect_list_elements(md)
    recipes = []
    md.gsub(/(\=|\:|\#)\[(.*?)\]/) do |*|
      case $1
        when ":" 
          recipes.push([Component.to_s, $2])
        when "#" 
          recipes.push([List.to_s, $2])
        when "=" 
          recipes.push([Recipe.to_s, $2])
      end
    end
    return recipes
  end
end