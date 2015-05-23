class CustomMarkdown
  include ActiveModel::Model

  def self.model_for_symbol(symbol)
    return {
      ":" => Component,
      "#" => List,
      "=" => Recipe
    }[symbol]
  end

  def self.convert_links_in_place(md)
    md.gsub!(/(\=|\:|\#)\[(.*?)\]/) do |*|
      element = model_for_symbol($1).find(:first, :conditions => ["lower(name) = ?", $2.downcase])
      if element
        "<a href='#{element.url}'>#{$2}</a>"
      else
        $2
      end
    end
    md
  end

  def self.links_to_directory_code(md)
    elements = []
    md.gsub(/(\=|\:|\#)\[(.*?)\]/) do |*|
      elements.push([model_for_symbol($1).to_s, $2, "list_content"])
    end
  end
end
