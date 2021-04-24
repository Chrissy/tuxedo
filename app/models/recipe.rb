# frozen_string_literal: true

require 'redcarpet'
require 'redcarpet/render_strip'
require 'component.rb'
require 'custom_markdown.rb'

class Recipe < ActiveRecord::Base
  include AlgoliaSearch
  acts_as_taggable
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods

  friendly_id :custom_name, use: :slugged
  serialize :recommends, Array

  acts_as_markdown_list :recipe
  after_save :delete_and_save_tags

  search_index = ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'] == 'test'  ? 'primary_development' : 'primary'

  algoliasearch index_name: search_index, id: :algolia_id do
    attributes :name, :description_as_plain_text, :recipe_as_plain_text, :image_with_backup, :url
  end

  def markdown_renderer
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
  end

  def plaintext_renderer
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
  end

  def convert_recipe_to_html_and_store
    update_attribute(:stored_recipe_as_html, convert_recipe_to_html)
  end

  def recipe_as_html
    (stored_recipe_as_html || convert_recipe_to_html).html_safe
  end

  def description_to_html
    converted_description = CustomMarkdown.convert_recommended_bottles_in_place(
      CustomMarkdown.convert_links_in_place(description)
    )
    markdown_renderer.render(converted_description).html_safe
  end

  def description_as_plain_text
    converted_description = CustomMarkdown.remove_custom_links(description)
    plaintext_renderer.render(converted_description)
  end

  def delete_and_save_tags
    if tags_as_text.present? && saved_changes.keys.include?('tags_as_text')
      tags.delete_all
      tag_list.add(tags_as_text.split(',').map(&:strip).map(&:downcase))
    end
  end

  def subtitle_with_fallback
    subtitle.present? ? subtitle : description_as_plain_text.split('. ')[0]
  end

  def recipe_as_plain_text
    components.map(&:name).join(', ')
  end

  def backup_image_url
    'shaker.jpg'
  end

  def image_with_backup
    image.present? ? image : backup_image_url
  end

  def adapted_from_for_display
    markdown_renderer.render(adapted_from).html_safe
  end

  def url
    "/#{slug}"
  end

  def classic?
    tag_list.include?('classic')
  end

  def original?
    tag_list.include?('original')
  end

  def custom_name
    name + ' cocktail recipe'
  end

  def type_for_display
    'recipe'
  end

  def edit_url
    "/edit/#{id}"
  end

  def delete_url
    ''
  end

  def make_my_number_last!
    update_attribute(:created_at, Time.now)
  end

  def number
    return Recipe.where(published: true).count + 1 if !published
    Recipe.where(published: true).order('created_at ASC').find_index(self) + 1
  end

  def self.all_for_home
    Recipe.where(published: true).order('created_at DESC')
  end

  def self.all_for_display
    where(published: true).order('lower(name)')
  end

  def self.newest_published
    all_for_home.first
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%' AND published = 't'")
  end

  # this is for manual use only, very slow
  def self.rebuild_all
    Recipe.all.map(&:delete_and_save_relationships)
    Recipe.all.map(&:touch)
  end

  def get_recommends(component, count = 3)
    other_recipes = (component.list_elements.keep_if(&:published?) - [self])
    other_recipes.sort_by! { |recipe| (components & recipe.components).length }
    other_recipes.reverse!.first(count)
  end

  def recommends(count)
    return [] unless components

    recommends = []

    components.each do |component|
      recommends.concat(get_recommends(component, 6))
      break unless recommends.length < count
    end

    return [] if recommends.empty?

    recommends.uniq.first(count)
  end

  def tagline
    "#{name} Cocktail | Tuxedo No.2"
  end

  def subtext
    'recipes/subtext'
  end

  def link
    "<a href='#{url}' class='recipe'>#{name}</a>"
  end

  def convert_recipe_to_html
    html = CustomMarkdown.convert_links_in_place(recipe.dup)

    html.gsub!(/^\* (.*?\n)/) do |*|
      CustomMarkdown.consruct_recipe_line(Regexp.last_match(1))
    end

    markdown_renderer.render(html)
  end

  def algolia_id
    "recipe_#{id}"
  end
end
