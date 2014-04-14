require 'component.rb'

class Recipe < ActiveRecord::Base
  serialize :components, Array

  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
  end

  def recipe_to_html
    markdown_to_html_with_components(recipe).html_safe
  end

  def description_to_html
    markdown.render(description).html_safe
  end

  private

  def markdown_to_html_with_components(md)
    component_list = []
    md.gsub!(/\:\[(.*?)\]/) do |*|
      component = Component.find_or_create_by(name: $1)
      component_list << component
      component.link
    end
    self.update_attribute(:components, component_list)
    markdown.render(md)
  end
end