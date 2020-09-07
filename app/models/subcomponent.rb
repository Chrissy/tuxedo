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
    # not sure why this is in here but might need it for something ¯\_(ツ)_/¯
    # shares_subcomponent.concat(component.list_elements)
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

  def illustration
    component.illustration
  end

  def subtitle
    component.subtitle
  end

  def default_list_markdown
    name.present? ? ":[#{name} 100]" : ''
  end

  def subcomponent?
    true
  end

  def subtext
    'components/subtext'
  end

  def classic_recipes(count = 3)
    list_elements.sort_by(&:created_at).reverse.sort_by { |a| a.classic? ? 0 : 1 }.uniq[0..count - 1]
  end

  def latest_recipes(count = 3, start = 0)
    list_elements.sort_by(&:created_at).reverse[start..(start + count - 1)]
  end

  def original_recipes(count = 3)
    list_elements.sort_by(&:created_at).reverse.sort_by { |a| a.original? ? 0 : 1 }[0..count - 1]
  end

  def skip_subcomponent_search
    component.skip_subcomponent_search
  end

  def featured_recipes(count = 3)
    classics = classic_recipes(2)
    latest = latest_recipes(2)
    originals = latest_recipes(2)
    featured = [
      classics[0],
      latest[0],
      originals[0],
      classics[1],
      latest[1],
      originals[1]
    ].uniq - [nil]
    featured.slice(0, count)
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
