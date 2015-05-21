class CustomMarkdown

  def self.model_for_symbol(symbol)
    return {
      ":" => Component,
      "#" => List,
      "=" => Recipe
    }[symbol]
  end

  def self.convert_links(md)
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
end
