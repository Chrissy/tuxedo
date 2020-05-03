# frozen_string_literal: true

require 'recipe.rb'
require 'subcomponent.rb'

class Component < ActiveRecord::Base
  include AlgoliaSearch
  acts_as_taggable
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods

  friendly_id :custom_name, use: :slugged

  acts_as_markdown_list :list_as_markdown

  serialize :recipe_ids, Array
  has_many :pseudonyms, as: :pseudonymable, dependent: :destroy
  has_many :subcomponents, as: :subcomponent, dependent: :destroy
  after_save :delete_and_save_subcomponents, :create_pseudonyms_if_changed, :delete_and_save_tags

  alias list_elements_from_markdown list_elements

  search_index = ENV['RAILS_ENV'] == 'development' ? 'primary_development' : 'primary'

  algoliasearch index_name: search_index, id: :algolia_id do
    attributes :name, :description_as_plain_text, :image_with_backup, :count_for_display, :url
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

  def subcomponents
    Subcomponent.where(component_id: id)
  end

  def parent_elements
    Relationship.where(child_type: self.class.to_s, child_id: id, field: :recipe).map(&:relatable).keep_if(&:published?)
  end

  def custom_name
    name + ' cocktail recipes'
  end

  def type_for_display
    'ingredient'
  end

  def edit_url
    "/ingredients/edit/#{id}"
  end

  def backup_image_url
    'shaker.jpg'
  end

  def published?
    true
  end

  def image_with_backup
    if image.present?
      image
    elsif list_elements.last.try(:image).try(:present?)
      list_elements.first.image
    elsif all_elements.last.try(:image).try(:present?)
      all_elements.first.image
    else
      backup_image_url
    end
  end

  def tagline
    "#{name.titleize} Cocktail Recipes | Tuxedo No.2"
  end

  def associated_component_ids
    ids = all_elements.map(&:id)
    Relationship.where(child_type: 'Component', relatable_type: 'Recipe', relatable_id: ids).map(&:child_id)
  end

  def pairings
    pairings = []
    associations = associated_component_ids

    associations.each do |association_id|
      if pairings.any? { |e| e[:id] == association_id } || association_id == id
        next
      end

      pairings << {
        count: associations.count { |e| e == association_id },
        id: association_id
      }
    end

    pairings
  end

  def common_pairings(count = 3)
    pairings.sort_by { |pair| pair[:count] }.reverse.slice(0, count).map do |pair|
      {
        component: Component.find_by_id(pair[:id]),
        count: pair[:count]
      }
    end
  end

  def subtext
    'components/subtext'
  end

  def all_elements
    all = []
    subcomponents.each { |subcomponent| all.concat(subcomponent.list_elements) }
    all.concat(list_elements)
  end

  def classic_recipes(count = 3)
    all_elements.sort_by { |a| a.classic? ? 0 : 1 }.slice(0, count).sort_by(&:created_at).reverse
  end

  def latest_recipes(count = 3)
    all_elements.sort_by(&:created_at).reverse.slice(0, count)
  end

  def original_recipes(count = 3)
    all_elements.sort_by { |a| a.original? ? 0 : 1 }.slice(0, count).sort_by(&:created_at).reverse
  end

  def featured_recipes(count = 3)
    classics = classic_recipes(2)
    latest = latest_recipes(2)
    originals = latest_recipes(2)
    featured = [
      classics[0],
      latest[0],
      originals[0],
      classics[1],
      latest[1],
      originals[1]
    ].uniq - [nil]
    featured.slice(0, count)
  end

  def count_for_display
    "#{list_elements.count} cocktails"
  end

  def nickname
    nick.present? ? nick : name
  end

  def pseudonyms
    Pseudonym.where(pseudonymable_id: id)
  end

  def pseudonyms_as_array
    pseudonyms_as_markdown.split(',').map(&:strip).map(&:downcase)
  end

  def create_pseudonyms_if_changed
    if pseudonyms_as_markdown && saved_changes.keys.include?('pseudonyms_as_markdown')
      create_pseudonyms
    end
  end

  def delete_and_save_subcomponents
    if description.present? && saved_changes.keys.include?('description')
      CustomMarkdown.subcomponents_from_markdown(self, description)
    end
  end

  def markdown_renderer
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
  end

  def plaintext_renderer
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
  end

  def description_to_html
    converted_description = CustomMarkdown.convert_recommended_bottles_in_place(
      CustomMarkdown.convert_links_in_place(description)
    )
    markdown_renderer.render(converted_description).html_safe
  end

  def substitutes_as_html
    substitutes_as_markdown ? markdown_renderer.render(substitutes_as_markdown).html_safe : nil
  end

  def description_as_plain_text
    converted_description = CustomMarkdown.remove_custom_links(description)
    plaintext_renderer.render(converted_description)
  end

  def subcomponent?
    false
  end

  def create_pseudonyms
    pseudonyms.delete_all
    pseudonyms_as_array.each do |name|
      Pseudonym.create(pseudonymable: self, name: name)
    end
  end

  def delete_and_save_tags
    if tags_as_text.present? && saved_changes.keys.include?('tags_as_text')
      tag_list.add(tags_as_text.split(',').map(&:strip).map(&:downcase))
    end
  end

  def list_for_textarea_with_default
    list_as_markdown || default_list_markdown
  end

  def default_list_markdown
    name.present? ? ":[#{name} 100]" : ''
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end

  def self.all_for_display
    order('lower(name)')
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%'")
  end

  def algolia_id
    "component_#{id}"
  end
end
