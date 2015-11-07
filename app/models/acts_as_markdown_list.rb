module ActsAsMarkdownList
  module ActsAsMethods
    def acts_as_markdown_list(options = {})
      include ActsAsMarkdownList

      has_many :relationships, as: :relatable, dependent: :destroy
      after_save :create_relationships
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def elements
    relationships.map do |rel|
      rel.expand || rel.child
    end.flatten.uniq.keep_if { |element| element.try(:published?) }
  end

  def recipes
    relationships.select{ |rel| rel.child_type == "Recipe" }.map(&:child).keep_if { |element| element.published? }
  end

  def create_relationships
    delete_and_save_relationships if content_as_markdown_changed?
  end

  def delete_and_save_relationships
    if relationships_from_markdown.present? && self.id
      relationships.delete_all
      Relationship.create(relationships_from_markdown)
    end
  end

  def relationships_from_markdown
    CustomMarkdown.relationships_from_markdown(self, content_as_markdown, :in_list_content)
  end
end
