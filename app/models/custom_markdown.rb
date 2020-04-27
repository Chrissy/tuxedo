# frozen_string_literal: true

class CustomMarkdown
  include ActiveModel::Model

  def self.model_for_symbol(symbol)
    {
      ':' => Component,
      '#' => List,
      '=' => Recipe,
      '::' => Subcomponent
    }[symbol]
  end

  def self.convert_links_in_place(md)
    return '' unless md.present?

    newMd = md.gsub(/(\=|\:\:|\:|\#)\[(.*?)\]/) do |*|
      element = model_for_symbol(Regexp.last_match(1)).where('lower(name) = ?', Regexp.last_match(2).downcase).first
      # for in-recipe subcomponents (:)
      if Regexp.last_match(1) == ':'
        subcomponent = Subcomponent.where('lower(name) = ?', Regexp.last_match(2).downcase).first
        element = subcomponent if subcomponent.present?
      end

      # for in-component subcomponents (::)
      if element && element.class.to_s == 'Subcomponent' && Regexp.last_match(1) == '::'
        match = Regexp.last_match(2)
        count = Subcomponent.find_by_name(match).try(:list_elements).try(:count) || 0
        slug = ApplicationHelper.slugify(match)
        "<h2 id='#{slug}' class='subcomponent'>#{match} • <a href='#{element.url}?type=#{slug}'>#{count} recipes</a></h2>"
      elsif element
        "<a href='#{element.url}'>#{Regexp.last_match(2)}</a>"
      else
        Regexp.last_match(2)
      end
    end
    newMd
  end

  def self.convert_recommended_bottles_in_place(md)
    return '' unless md.present?

    newMd = md.gsub(/(\&)\[(.*?)\]/) do |*|
      "<div class='recommended-bottles'>#{Regexp.last_match(2).gsub(/(\$+)/, '<em>\1</em>')}</div>"
    end
    newMd
  end

  def self.remove_custom_links(md)
    return '' unless md.present?

    newMd = md.gsub(/(\=|\:|\:\:|\#|\&)\[(.*?)\]/) do |*|
      Regexp.last_match(2)
    end
    newMd
  end

  def self.links_to_code_array(md)
    return '' unless md.present?

    elements = []
    md.gsub(/(\=|\:|\#)\[(.*?)\]/) do |*|
      attempted_expansion = attempt_to_expand_code(Regexp.last_match(2), Regexp.last_match(1))
      if attempted_expansion
        elements.concat(attempted_expansion)
      else
        arr = [model_for_symbol(Regexp.last_match(1)).to_s, Regexp.last_match(2)]
        if Regexp.last_match(1) == ':'
          subcomponent = Subcomponent.where('lower(name) = ?', Regexp.last_match(2).downcase).first
          arr[0] = 'Subcomponent' if subcomponent.present?
        end
        elements << arr
      end
    end
    elements.uniq - ['', nil]
  end

  def self.attempt_to_expand_code(collection_code, symbol)
    first_word = collection_code[/(?:(?!\d+).)*/].strip
    limit_number = collection_code[/\d+/].to_i
    sort_by = collection_code[/(\bDATE\b)/]
    return false if first_word.blank? || limit_number.zero? || symbol == '='

    elements = if first_word == 'ALL' || first_word == 'all'
                 shorthand_to_recipes(limit_number, sort_by)
               else
                 shorthand_to_component_recipes(first_word, sort_by)
               end
  end

  def self.shorthand_to_recipes(limit_number, sort_by)
    Recipe.limit(limit_number).order(sort_by.nil? ? 'name asc' : 'last_updated desc').map { |el| [el.class.to_s, el.id] }
  end

  def self.subcomponents_from_markdown(instance, md)
    elements = []
    md.scan(/\:\:\[(.*?)\]/) do
      element =
        Subcomponent.find_by_name(Regexp.last_match(1)) ||
        Subcomponent.create(name: Regexp.last_match(1), component_id: instance.id)
      elements << element
    end
    elements.uniq - ['', nil]
  end

  def self.shorthand_to_component_recipes(component_name, _sort_by)
    component = Component.find_by_name(component_name)
    [['Component', component.id, :expandable_list_content]]
  end

  def self.relationships_from_markdown(instance, md, field)
    links_to_code_array(md.dup).map do |code|
      type = code[0].constantize
      element =
        type.find_by_name(code[1].to_s) ||
        type.find_by_id(code[1].to_s)

      if field == :recipe && !element && code[0] === 'Component'
        element = Subcomponent.find_by_name(code[1].to_s)
      end
      element = type.create(name: code[1]) if field == :recipe && !element

      next unless element

      {
        relatable: instance,
        child_id: element.id,
        child_type: element.class.to_s,
        field: code[2] || field
      }
    end.compact
  end
end
