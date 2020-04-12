# frozen_string_literal: true

require 'recipe.rb'
require 'component.rb'
require 'custom_markdown.rb'
require 'image_uploader.rb'

class List < ActiveRecord::Base
  include AlgoliaSearch
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods

  friendly_id :custom_name, use: :slugged

  acts_as_markdown_list :content_as_markdown
  after_save :create_images

  search_index = ENV['RAILS_ENV'] == 'development' ? 'primary_development' : 'primary'

  algoliasearch index_name: search_index, id: :algolia_id do
    attributes :name, :image_with_backup, :count_for_display, :url
  end

  def elements
    list_elements
  end

  def url
    "/list/#{slug}"
  end

  def custom_name
    name + ' cocktail recipes'
  end

  def type_for_display
    'list'
  end

  def edit_url
    "/list/edit/#{id}"
  end

  def published?
    true
  end

  def self.all_for_display
    where('component IS NULL', order: 'lower(name)')
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%' AND component IS NULL")
  end

  def tagline
    if home?
      'Tuxedo No.2'
    else
      "#{name} | Tuxedo No.2"
    end
  end

  def subtext
    'components/subtext'
  end

  def count_for_display
    "#{elements.count} cocktails"
  end

  def link
    "<a href='#{url}' class='list'>#{name}</a>"
  end

  def backup_image_url
    'shaker.jpg'
  end

  def create_images
    if image.present? && saved_changes.keys.include?('image')
      ImageUploader.new(image).upload
    end
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
    name == 'Home' || name == 'home'
  end

  def header_element
    home? ? elements.first : self
  end

  def algolia_id
    "list_#{id}"
  end
end
