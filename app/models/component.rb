require 'recipe.rb'

class Component < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged

  serialize :recipe_ids, Array
  has_many :psuedonyms, as: :pseudonymable, dependent: :destroy
  before_save :create_pseudonyms

  def recipes
    recipe_relationships.map(&:relatable)
  end

  def recipe_relationships
    Relationship.where(child_type: self.class.to_s, child_id: id, why: :in_recipe_content)
  end

  def url
    "/ingredients/#{slug}"
  end

  def custom_name
    name + " cocktail recipes"
  end

  def edit_url
    "/ingredients/edit/#{id}"
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

  def list_for_textarea
    list_as_markdown ? list_as_markdown : ":[#{name} 100]"
  end

  def pseudonyms_as_array
    psuedonyms_as_markdown.split(",").map(&:strip).map(&:downcase)
  end

  def create_pseudonyms
    pseudonyms_as_array.each do |name|
      Pseudonym.create({pseudonymable: self, name: name})
    end
  end

  def create_or_update_list
    if list
      List.find(list).update_attributes(content_as_markdown: list_for_textarea, component: id)
    else
      list_element = List.create(content_as_markdown: list_for_textarea, name: name, component: id)
      update_attribute(:list, list_element.id)
    end
  end

  def list_elements
    recipes
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end
end
