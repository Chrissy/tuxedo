require 'recipe.rb'
require 'component.rb'

class Directory
  include ActiveModel::Model
  attr_accessor :element_codes, :parent_element_codes

  def children
    to_elements(element_codes)
  end

  def child_recipes
    find_by_model(Recipe)
  end

  def child_components
    find_by_model(Component)
  end

  def child_lists
    find_by_model(List)
  end

  def parents
  end

  def parent_lists
  end

  def parent_recipes
  end

  private

  def to_elements(codes)
    elements = []
    codes.each do |element_code|
      elements << (collection_code_to_elements(element_code[1]) || element_code_to_element(element_code))
    end
    elements = elements.flatten.uniq - ["",nil]
    elements.keep_if { |element| element.published? }
  end

  def find_by_model(filtering_model)
    filtered_codes = element_codes.select{|code| code[0] == filtering_model.to_s }
    to_elements(filtered_codes)
  end

  def element_code_to_element(element_code)
    element_code[0].singularize.classify.constantize.find_by_name(element_code[1])
  end

  def collection_code_to_elements(collection_code)
    first_word = collection_code[/(?:(?!\d+).)*/].strip
    limit_number = collection_code[/\d+/].to_i
    sort_by = collection_code[/(\bDATE\b)/]
    return false if first_word.blank? || limit_number.zero?
    if first_word == "ALL" || first_word == "all"
      shorthand_to_recipes(limit_number, sort_by)
    else
      shorthand_to_components(first_word, sort_by)
    end
  end

  def shorthand_to_recipes(limit_number, sort_by)
    Recipe.limit(limit_number).order(sort_by.nil? ? "name asc" : "last_updated desc").to_a
  end

  def shorthand_to_components(component_name, sort_by)
    component = Component.find_by_name(component_name)
    return if component.nil?
    if sort_by.nil?
      component.recipes.sort_by!(&:name)
    else
      component.recipes.sort { |a,b| a.last_updated <=> b.last_updated }
    end
  end
end
