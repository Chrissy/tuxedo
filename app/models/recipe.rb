class Recipe < ActiveRecord::Base
  serialize :components, Array

  def recipe_to_html
    markdown_and_components = markdown_to_html(recipe)
    self.components = markdown_and_components[1]
    self.save
    markdown_and_components[0].html_safe
  end

  private

  def markdown_to_html(md)
    component_list = []
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
    md.gsub!(/\:\[(.*?)\]/) do |*|
      component = Component.find_or_create_by(name: $1)
      component_list << component.name
      component.link
    end
    md.gsub!(/\#\[(.*?)\]/) do |*|
      label = $1
      "<div class='section-label #{label.gsub(/[ ]/,"-")}'>#{label}</div>"
    end
    [markdown.render(md), component_list]
  end

end