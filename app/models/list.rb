require 'recipe.rb'
require 'component.rb'
require 'custom_markdown.rb'
require 'image_uploader.rb'

class List < ActiveRecord::Base
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods

  friendly_id :custom_name, use: :slugged

  acts_as_markdown_list :content_as_markdown
  after_save :create_images

  def elements
    list_elements
  end

  def url
    "/list/#{slug}"
  end

  def custom_name
    name + " cocktail recipes"
  end

  def type_for_display
    "list"
  end

  def edit_url
    "/list/edit/#{id}"
  end

  def published?
    true
  end

  def self.all_for_display
    all(conditions: "component IS NULL", order: "lower(name)")
  end

  def self.get_by_letter(letter)
    all(conditions: "lower(name) LIKE '#{letter}%' AND component IS NULL")
  end

  def tagline
    if home?
      "Tuxedo No.2"
    else
      "#{name} | Tuxedo No.2"
    end
  end

  def subtext
    "components/subtext"
  end

  def count_for_display
    "#{elements.count} cocktails"
  end

  def link
    "<a href='#{url}' class='list'>#{name}</a>"
  end

  def backup_image_url
    "shaker.jpg"
  end

  def create_images
    ImageUploader.new(image).upload if image.present? && image_changed?
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
