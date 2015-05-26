require 'recipe.rb'
require 'component.rb'
require 'custom_markdown.rb'

class List < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged

  serialize :element_ids, Array

  has_many :relationships, as: :relatable, dependent: :destroy

  def elements
    relationships.map(&:child).keep_if { |element| element.published? }

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

  def published?
    true
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
    "#{elements.count} cocktails"
  end

  def recipes
    relationships.select{ |rel| rel.child_type == "Recipe" }.map(&:child).keep_if { |element| element.published? }
  end

  def link
    "<a href='#{url}' class='list'>#{name}</a>"
  end

  def backup_image_url
    "https://www.filepicker.io/api/file/drOikI0sTqG2xjWn2WSQ/convert?fit=crop&amp;h=861&amp;w=1500&amp"
  end

  def image_with_backup
    if image.present?
      image
    elsif elements.last.try(:image).try(:present?)
      elements.first.image
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

  def create_relationships
    code_array = CustomMarkdown.links_to_code_array(content_as_markdown)

    to_create = code_array.map do |code|
      element = code[0].constantize.find_by_name(code[1])

      return unless element

      {
        relatable: self,
        child_id: element.id,
        child_type: code[0],
        why: "in_list_content"
      }
    end

    relationships.delete_all
    Relationship.create(to_create)
  end
end
