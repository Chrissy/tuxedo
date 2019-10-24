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
      element = model_for_symbol($1).where("lower(name) = ?", $2.downcase).first
      if element
        "<a href='#{element.url}'>#{$2}</a>"
      else
        $2
      end
    end
    md
  end

  def self.links_to_code_array(md)
    elements = []
    md.gsub(/(\=|\:|\#)\[(.*?)\]/) do |*|
      attempted_expansion = attempt_to_expand_code($2, $1)
      if attempted_expansion
        elements.concat(attempted_expansion)
      else
        elements << [model_for_symbol($1).to_s, $2]
      end
    end
    elements.uniq - ["",nil]
  end

  def self.attempt_to_expand_code(collection_code, symbol)
    first_word = collection_code[/(?:(?!\d+).)*/].strip
    limit_number = collection_code[/\d+/].to_i
    sort_by = collection_code[/(\bDATE\b)/]
    return false if first_word.blank? || limit_number.zero? || symbol == "="
    if first_word == "ALL" || first_word == "all"
      elements = shorthand_to_recipes(limit_number, sort_by)
    else
      elements = shorthand_to_component_recipes(first_word, sort_by)
    end
  end

  def self.shorthand_to_recipes(limit_number, sort_by)
    Recipe.limit(limit_number).order(sort_by.nil? ? "name asc" : "last_updated desc").map{ |el| [el.class.to_s, el.id]}
  end

  def self.shorthand_to_component_recipes(component_name, sort_by)
    component = Component.find_by_name(component_name)
    [["Component", component.id, :expandable_list_content]]
  end

  def self.relationships_from_markdown(instance, md, field)
    self.links_to_code_array(md.dup).map do |code|
      type = code[0].constantize
      element =
                type.find_by_name(code[1].to_s) ||
                type.find_by_id(code[1].to_s) ||
                (type.create(:name => code[1]) if field == :recipe)

      next unless element

      {
        relatable: instance,
        child_id: element.id,
        child_type: code[0],
        field: code[2] || field
      }
    end.compact
  end
end
