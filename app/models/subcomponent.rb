require 'recipe.rb'

class Subcomponent < ActiveRecord::Base
  belongs_to :component, :foreign_key => true

  def search_data
    {
      name: name,
    }
  end

  def component
    Component.find(component_id)
  end

  def url
    component.url
  end

  def list_for_textarea_with_default
    list_as_markdown || default_list_markdown
  end

  def default_list_markdown
    name.present? ? ":[#{name} 100]" : ""
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end

  def self.all_for_display
    order("lower(name)")
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%'")
  end
end
