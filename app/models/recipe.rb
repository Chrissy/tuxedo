require 'component.rb'

class Recipe < ActiveRecord::Base
  serialize :component_ids, Array

  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
  end

  def recipe_to_html
    markdown_to_html_with_components(recipe).html_safe
  end

  def description_to_html
    markdown.render(description).html_safe
  end

  def components
    component_ids.map { |component_id| Component.find(component_id) }
  end

  def update_components
    components.each do |component|
      component.recipe_ids.push(self.id).uniq!
      component.save
    end
  end

  private

  def markdown_to_html_with_components(md)
    component_list = []
    md.gsub!(/\:\[(.*?)\]/) do |*|
      component = Component.find_or_create_by(name: $1)
      component_list << component.id
      component.link
    end
    self.update_attribute(:component_ids, component_list)
    update_components()
    markdown.render(md)
  end
end