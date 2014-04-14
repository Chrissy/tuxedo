require 'component.rb'

class Recipe < ActiveRecord::Base
  serialize :components, Array

  def recipe_to_html
    markdown_to_html(recipe).html_safe
  end

  private

  def markdown_to_html(md)
    component_list = []
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
    md.gsub!(/\:\[(.*?)\]/) do |*|
      component = Component.find_or_create_by(name: $1)
      component_list << component
      component.link
    end
    md.gsub!(/\#\[(.*?)\]/) do |*|
      label = $1
      "<div class='section-label #{label.gsub(/[ ]/,"-")}'>#{label}</div>"
    end
    self.update_attribute(:components, component_list)
    markdown.render(md)
  end

end