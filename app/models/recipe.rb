class Recipe < ActiveRecord::Base

  def recipe_to_html
    markdown_to_html(recipe).html_safe
  end

  private

  def markdown_to_html(md)
    md.gsub(/\:\[(.*?)\]/) do |*|
      Component.find_or_create_by(name: $1).link
    end
  end

end