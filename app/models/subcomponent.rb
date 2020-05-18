# frozen_string_literal: true

require 'recipe.rb'

class Subcomponent < ActiveRecord::Base
  belongs_to :component, foreign_key: true

  def search_data
    {
      name: name
    }
  end

  def component
    Component.find(component_id)
  end

  def url
    component.url
  end

  def url_with_hash
    "#{component.url}##{ApplicationHelper.slugify(name)}"
  end

  def list_elements
    shares_subcomponent = Relationship.where(
      child_type: 'Subcomponent',
      relatable_type: 'Recipe',
      child_id: id
    ).map(&:relatable)
    shares_subcomponent.concat(component.list_elements)
    shares_subcomponent
  end

  def list_for_textarea_with_default
    list_as_markdown || default_list_markdown
  end

  def image_with_backup
    if list_elements.last.try(:image).try(:present?)
      list_elements.last.image
    elsif component.list_elements.last.try(:image).try(:present?)
      component.list_elements.last.image
    else
      component.backup_image_url
    end
  end

  def default_list_markdown
    name.present? ? ":[#{name} 100]" : ''
  end

  def subcomponent?
    true
  end

  def nickname
    name
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end

  def self.all_for_display
    order('lower(name)')
  end

  def self.get_by_letter(letter)
    where("lower(name) LIKE '#{letter}%'")
  end
end
