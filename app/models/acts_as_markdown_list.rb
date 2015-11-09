module ActsAsMarkdownList
  module ActsAsMethods

    def acts_as_markdown_list(markdown_field, options = {})
      has_many :relationships, as: :relatable, dependent: :destroy
      after_save :create_relationships

      define_method(:markdown) do
        send(markdown_field) || (send(options[:default]) if options[:default].present?) || ""
      end

      define_method(:list_elements) do
        relationships.map do |rel|
          rel.expand || rel.child
        end.flatten.uniq.keep_if { |element| element.try(:published?) }
      end

      define_method(:recipes) do
        relationships.select{ |rel| rel.child_type == "Recipe" }.map(&:child).keep_if { |element| element.published? }
      end

      define_method(:create_relationships) do
        delete_and_save_relationships if send("#{markdown_field}_changed?")
      end

      define_method(:delete_and_save_relationships) do
        if relationships_from_markdown.present? && self.id
          relationships.delete_all
          Relationship.create(relationships_from_markdown)
        end
      end

      define_method(:relationships_from_markdown) do
        CustomMarkdown.relationships_from_markdown(self, markdown, :in_list_content)
      end

    end
  end
end
