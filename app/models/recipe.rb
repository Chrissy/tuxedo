class Recipe < ActiveRecord::Base

  def recipe_to_html
    markdown_to_html(recipe).html_safe
  end

  private

  def markdown_to_html(md)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, extensions = {})
    md.gsub!(/\:\[(.*?)\]/) do |*|
      Component.find_or_create_by(name: $1).link
    end
    md.gsub!(/\#\[(.*?)\]/) do |*|
      label = $1
      "<div class='section-label #{label.gsub(/[ ]/,"-")}'>#{label}</div>"
    end
    markdown.render(md)
  end

end