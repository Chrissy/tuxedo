require 'recipe.rb'

class Component < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged

  serialize :recipe_ids, Array
  serialize :akas, Array

  def recipes
    recipe.relationships.map(&:parent)
  end
  
  def recipe_relationships
    Relationship.where(child_type: child.class.to_s, child_id: child.id, why: :in_recipe_content)
  end

  def self_or_aka
    if is_an_aka?
      aka
    else
      self
    end
  end

  def list_with_aka
    if is_an_aka?
      aka.list
    else
      list
    end
  end

  def url
    "/ingredients/#{slug}"
  end

  def custom_name
    name + " cocktail recipes"
  end

  def edit_url
    if is_an_aka?
      "/ingredients/edit/#{aka.id}"
    else
      "/ingredients/edit/#{id}"
    end
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
    elsif aka && aka.image.present?
      aka.image
    elsif recipes.last.try(:image).try(:present?)
      recipes.last.image
    else
      backup_image_url
    end
  end

  def tagline
    "#{name.titleize} Cocktail Recipes | Tuxedo no.2"
  end

  def subtext
    "components/subtext"
  end

  def count_for_display
    "#{list_elements.count} cocktails"
  end

  def nickname
    nick.present? ? nick : name
  end

  def aka
    Component.find_by_id(aka_id)
  end

  def is_an_aka?
    aka_id.present?
  end

  def compile_akas
    aka_list = []
    akas_as_markdown.split(",").each do |aka_name|
      new_aka = Component.find_or_create_by_name(aka_name.strip.downcase)
      new_aka.update_attribute(:aka_id, id)
      aka_list.push(new_aka)
    end
    (akas - aka_list).map(&:destroy)
    update_attribute(:akas, aka_list)
  end

  def has_list
    !list.nil?
  end

  def list_for_textarea #MARKDOWN
    list_for = List.find_by_id(list)
    list_for ? list_for.content_as_markdown : ":[#{name} 100]"
  end

  def create_or_update_list(markdown)
    has_list ? update_list(markdown) : create_list(markdown)
  end

  def update_list(markdown)
    list_element = List.find(list)
    list_element.update_attributes(content_as_markdown: markdown, component: id)
    list_element.create_relationships
  end

  def create_list(markdown)
    list_element = List.new(content_as_markdown: markdown, name: name, component: id)
    list_element.create_relationships
    update_attribute(:list, list_element.id)
  end

  def list_elements
    list_with_aka.nil? ? recipes : List.find(list_with_aka).elements
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end
end
