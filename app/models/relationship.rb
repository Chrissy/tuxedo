require 'recipe.rb'
require 'component.rb'
require 'list.rb'
require 'custom_markdown.rb'

class Relationship < ActiveRecord::Base

  belongs_to :relatable, :polymorphic => true
  before_save :generate_key

  def child
    child_type.constantize.find(child_id)
  end
  
  def parent
    relatable
  end

  def generate_key
    self.key = "#{relatable.class.to_s}_#{relatable.id}_#{child.class.to_s}_#{child.id}_#{why}"
    return false if self.class.exists?(:key => key)
  end

  def self.find_parents(child)
    relationships = where(child_type: child.class.to_s, child_id: child.id)
    relationships.map{|relationship| relationship.relatable}
  end
  
  def self.find_parents_by_type(child, type)
    relationships = where(child_type: child.class.to_s, child_id: child.id, relatable_type: type.to_s)
    relationships.map{|relationship| relationship.relatable}
  end
end
