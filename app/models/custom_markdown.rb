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
      model_for_symbol($1).find_by_name($2).try(:link) || $2
    end
    md
  end
end
