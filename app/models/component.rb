require 'recipe.rb'

class Component < ActiveRecord::Base
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods
  extend ActsAsIndexable::ActsAsMethods

  friendly_id :custom_name, use: :slugged

  acts_as_markdown_list :list_as_markdown
  acts_as_indexable

  serialize :recipe_ids, Array
  has_many :pseudonyms, as: :pseudonymable, dependent: :destroy
  before_save :create_pseudonyms_if_changed

  alias_method :list_elements_from_markdown, :list_elements

  def self.all_for_display
    all(order: "lower(name)")
  end

  def url
    "/ingredients/#{slug}"
  end

  def list_elements
    if list_elements_from_markdown.empty?
      parent_elements
    else
      list_elements_from_markdown
    end
  end

  def parent_elements
    Relationship.where(child_type: self.class.to_s, child_id: id, field: :recipe).map(&:relatable).keep_if(&:published?)
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
    elsif list_elements.last.try(:image).try(:present?)
      list_elements.last.image
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

  def pseudonyms_as_array
    pseudonyms_as_markdown.split(",").map(&:strip).map(&:downcase)
  end

  def create_pseudonyms_if_changed
    create_pseudonyms if pseudonyms_as_markdown && pseudonyms_as_markdown_changed?
  end

  def create_pseudonyms
    pseudonyms.delete_all
    pseudonyms_as_array.each do |name|
      Pseudonym.create({pseudonymable: self, name: name})
    end
  end

  def list_for_textarea_with_default
    list_as_markdown || default_list_markdown
  end

  def default_list_markdown
    name.present? ? ":[#{name} 100]" : ""
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end
end
