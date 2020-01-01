require 'redcarpet'
require 'redcarpet/render_strip'
require 'component.rb'
require 'custom_markdown.rb'
require 'image_uploader.rb'


class Recipe < ActiveRecord::Base
  searchkick highlight: [:description_as_plain_text, :recipe_as_plain_text]
  acts_as_taggable
  extend FriendlyId
  extend ActsAsMarkdownList::ActsAsMethods

  friendly_id :custom_name, use: :slugged
  serialize :recommends, Array

  acts_as_markdown_list :recipe
  after_save :create_images, :delete_and_save_tags

  def search_data
    {
      name: name,
      description: description_as_plain_text,
      recipe: recipe_as_plain_text
    }
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
    if tags_as_text.present? && saved_changes.keys.include?("tags_as_text")
      tag_list.add(tags_as_text.split(",").map(&:strip).map(&:downcase))
    end
  end

  def recipe_as_plain_text
    components.map(&:name).join(", ")
  end

  def create_images
    ImageUploader.new(image).upload if image.present? && saved_changes.keys.include?("image")
  end

  def backup_image_url
    "shaker.jpg"
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
    name + " cocktail recipe"
  end

  def type_for_display
    "recipe"
  end

  def edit_url
    "/edit/#{id}"
  end

  def delete_url
    ""
  end

  def make_my_number_last!
    update_attribute(:created_at, Time.now)
  end

  def number
    Recipe.where(:published => true).order('created_at ASC').find_index(self)
  end

  def self.compile_numbers_based_on_home
    time = Time.now
    List.find(1).elements.keep_if{|x|x.is_a?(Recipe)}.reverse.each_with_index do |recipe, x|
      recipe.update_attribute(:created_at, time + x)
    end
  end

  def self.all_for_display
    where(published: true).order("lower(name)")
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%' AND published = 't'")
  end

  def recommends
    return unless components

    other_recipes = (components.first.list_elements.keep_if(&:published?) - [self])
    other_recipes.sort_by!{ |recipe| (components & recipe.components).length }
    other_recipes.reverse!.first(3)
  end

  def tagline
    "#{name} Cocktail | Tuxedo No.2"
  end

  def subtext
    "recipes/subtext"
  end

  def link
    "<a href='#{url}' class='recipe'>#{name}</a>"
  end

  def convert_fractions(str)
   str.gsub(/\d+.(\d+)/) do |match|
     case match
     when "2.75" then '2¾'
     when "2.5" then '2½'
     when "2.25" then '2¼'
     when "1.75" then '1¾'
     when "1.5" then '1½'
     when "1.25" then '1¼'
     when "0.75" then '¾'
     when "0.6" then '⅔'
     when "0.3" then '⅓'
     when "0.5" then '½'
     when "0.25" then '¼'
     when "0.125" then '⅛'
     else match
     end
   end.html_safe
  end

  def wrap_units(md)
    md.gsub(/([0-9])(oz|tsp|tbsp|Tbsp|dash|dashes|lb|lbs|cup|cups)(\b)/) do |*|
      "#{$1}<span class='unit'>#{$2}</span>#{$3}"
    end
  end

  def convert_recipe_to_html
    html = CustomMarkdown.convert_links_in_place(recipe.dup)

    html.gsub!(/\* ([0-9].*?|fill) +/) do |*|
      modified_md = wrap_units($1)
      "* <span class='amount'>#{convert_fractions(modified_md)}</span> "
    end
    html.gsub!(/\# ?([A-Z].*?)/) do |*|
      "# " << ApplicationController.helpers.swash($1)
    end
    markdown_renderer.render(html)
  end
end
