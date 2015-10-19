module ActsAsMarkdownList
  module ActsAsMethods
    def acts_as_markdown_list(options = {})
      has_many :relationships, as: :relatable, dependent: :destroy
    end
  end
end
