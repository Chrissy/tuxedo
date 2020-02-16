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

  search_index = ENV['RAILS_ENV'] == 'development' ? 'primary_development' : 'primary'

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

  def lists
    Relationship.find_parents_by_type(self, List)
  end

  def url
    "/#{slug}"
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
    Recipe.where(published: true).order('created_at ASC').find_index(self)
  end

  def self.compile_numbers_based_on_home
    time = Time.now
    List.find(1).elements.keep_if { |x| x.is_a?(Recipe) }.reverse.each_with_index do |recipe, x|
      recipe.update_attribute(:created_at, time + x)
    end
  end

  def self.all_for_display
    where(published: true).order('lower(name)')
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%' AND published = 't'")
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

  def convert_fractions(str)
    str.gsub(/\d+.(\d+)/) do |match|
      case match
      when '2.75' then '2¾'
      when '2.5' then '2½'
      when '2.25' then '2¼'
      when '1.75' then '1¾'
      when '1.5' then '1½'
      when '1.25' then '1¼'
      when '0.75' then '¾'
      when '0.6' then '⅔'
      when '0.3' then '⅓'
      when '0.5' then '½'
      when '0.25' then '¼'
      when '0.125' then '⅛'
      else match
      end
    end.html_safe
  end

  def consruct_recipe_line(md)
    regex = /([0-9]*\.?[0-9]*)(oz|tsp|tbsp|Tbsp|dash|dashes|lb|lbs|cup|cups)(.*?)$/
    search = md.match(regex).to_a.drop(1) # first is complete match

    unless search[0]
      return "* <span class='amount'></span><span class='ingredient'>#{md}</span>\n"
    end

    unit = search[1] ? "<span class='unit'>#{search[1]}</span>" : ''
    "* <span class='amount'>#{convert_fractions(search[0])}#{unit}</span><span class='divider'></span><span class='ingredient'>#{search[2]}</span>\n"
  end

  def convert_recipe_to_html
    html = CustomMarkdown.convert_links_in_place(recipe.dup)

    html.gsub!(/^\* (.*?\n)/) do |*|
      consruct_recipe_line(Regexp.last_match(1))
    end

    markdown_renderer.render(html)
  end

  def algolia_id
    "recipe_#{id}"
  end
end
