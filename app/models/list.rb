require 'recipe.rb'
require 'component.rb'
require 'custom_markdown.rb'

class List < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged

  serialize :element_ids, Array
  after_save :tell_recipes_about_me

  def directory
    @directory ||= Directory.new(:element_codes => element_ids)
  end

  def elements
    directory.to_elements
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

  def recipes #ROLODEX
    element_ids.select{ |pair| pair[0] == "Recipe" }.map{ |pair| Recipe.find_by_name(pair[1])}.compact
  end

  def link
    "<a href='#{url}' class='list'>#{name}</a>"
  end

  def tell_recipes_about_me #ROLODEX
    recipes.each do |recipe|
      recipe.list_ids << self.id
      recipe.list_ids = recipe.list_ids.uniq
      recipe.save
    end
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

  def collect_and_save_list_elements
    self.update_attribute(:element_ids, CustomMarkdown.links_to_directory_code(content_as_markdown))
  end
end
