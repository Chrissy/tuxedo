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

  def self.links_to_code_array(md)
    elements = []
    md.gsub(/(\=|\:|\#)\[(.*?)\]/) do |*|
      elements << (attempt_to_expand_code($2) || [model_for_symbol($1).to_s, $2])
    end
    elements.uniq - ["",nil]
  end

  def self.attempt_to_expand_code(collection_code)
    first_word = collection_code[/(?:(?!\d+).)*/].strip
    limit_number = collection_code[/\d+/].to_i
    sort_by = collection_code[/(\bDATE\b)/]
    return false if first_word.blank? || limit_number.zero?
    if first_word == "ALL" || first_word == "all"
      elements = shorthand_to_recipes(limit_number, sort_by)
    else
      elements = shorthand_to_components(first_word, sort_by)
    end
    elements.map{ |el| [el.class.to_s, el.id]} if elements
  end

  def self.shorthand_to_recipes(limit_number, sort_by)
    Recipe.limit(limit_number).order(sort_by.nil? ? "name asc" : "last_updated desc").to_a
  end

  def self.shorthand_to_components(component_name, sort_by)
    component = Component.find_by_name(component_name)
    return if component.nil?
    if sort_by.nil?
      component.recipes.sort_by!(&:name)
    else
      component.recipes.sort { |a,b| a.last_updated <=> b.last_updated }
    end
  end
end
