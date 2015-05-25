require 'component.rb'
require 'custom_markdown.rb'

class Recipe < ActiveRecord::Base
  extend FriendlyId
  friendly_id :custom_name, use: :slugged

  serialize :component_ids, Array
  serialize :list_ids, Array
  serialize :recommends, Array
  before_save :touch_associated_lists

  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
  end

  def directory
    components = component_ids.map{ |id| ["Component", id, "recipe_content"]}
    lists = list_ids.map{ |id| ["List", id, "parent_list"]}
    @directory ||= Directory.new(:element_codes => components, :parent_element_codes => lists)
  end

  def recipe_to_html
    convert_recipe_to_html(recipe)
  end

  def recipe_as_html
    (stored_recipe_as_html || recipe_to_html).html_safe
  end

  def description_to_html #MARKDOWN
    converted_description = CustomMarkdown.convert_links(description)
    markdown.render(converted_description).html_safe
  end

  def backup_image_url
    "https://www.filepicker.io/api/file/drOikI0sTqG2xjWn2WSQ/convert?fit=crop&amp;h=861&amp;w=1500&amp"
  end

  def image_with_backup
    image.present? ? image : backup_image_url
  end

  def components
    directory.child_components
  end

  def lists
    directory.parent_lists
  end

  def url
    "/#{slug}"
  end

  def custom_name
    name + " cocktail recipe"
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

  def store_recommends
    recs = (components.first.recipes.keep_if(&:published?) - [self]).sort_by{ |recipe|
      (components & recipe.components).length
    }.reverse.first(3)
    update_attribute(:recommends, recs)
  end
  handle_asynchronously :store_recommends

  def tagline
    "#{name} Cocktail | Tuxedo no.2"
  end

  def subtext
    "recipes/subtext"
  end

  def link
    "<a href='#{url}' class='recipe'>#{name}</a>"
  end

  def update_components #ROLODEX
    components.each do |component|
      recipe_ids = component.recipe_ids.push(self.id).uniq
      component.update_attribute(:recipe_ids, recipe_ids)
    end
  end

  def self.update_all
    Recipe.all.each do |recipe|
      recipe.recipe_to_html
      recipe.update_components
    end
  end

  def convert_fractions(str)
   str.gsub(/0\.[0-9]*.*?/) do |match|
     case match
     when "0.5" then '½'
     when "0.25" then '¼'
     when "0.75" then '¾'
     when "0.3" then '⅓'
     when "0.6" then '⅔'
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

  private

  def touch_associated_lists #ROLODEX
    lists.each do |list|
      list.touch
    end
  end

  def convert_recipe_to_html(md) #MARKDOWN
    component_list = []
    md.gsub!(/\:\[(.*?)\]/) do |*|
      component = Component.find_or_create_by(name: $1)
      component_list << component.id
      component.link
    end
    self.update_attribute(:component_ids, component_list)
    update_components()
    md.gsub!(/\* ([0-9].*?|fill) +/) do |*|
      modified_md = wrap_units($1)
      "* <span class='amount'>#{convert_fractions(modified_md)}</span> "
    end
    md.gsub!(/\# ?([A-Z].*?)/) do |*|
      "# " << ApplicationController.helpers.swash($1)
    end
    html = markdown.render(md)
    update_attribute(:stored_recipe_as_html, html)
    html
  end
end
