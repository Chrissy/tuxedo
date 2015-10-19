require 'recipe.rb'
require 'component.rb'
require 'custom_markdown.rb'
require 'acts_as_markdown_list.rb'

class List < ActiveRecord::Base
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods

  friendly_id :custom_name, use: :slugged

  after_save :create_relationships

  serialize :element_ids, Array

  acts_as_markdown_list

  def elements
    relationships.map do |rel|
      rel.expand || rel.child
    end.flatten.uniq.keep_if { |element| element.try(:published?) }
  end

  def create_relationships
    delete_and_save_relationships if content_as_markdown_changed?
  end

  def delete_and_save_relationships
    if relationships_from_markdown.present? && self.id
      relationships.delete_all
      Relationship.create(relationships_from_markdown)
    end
  end

  def relationships_from_markdown
    CustomMarkdown.relationships_from_markdown(self, content_as_markdown, :in_list_content)
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
end
