require 'base64'

class CustomMarkdown
  include ActiveModel::Model

  def self.image_path(image, width, height)
    Base64.strict_encode64(
      JSON.generate(
        bucket: 'chrissy-tuxedo-no2',
        key: image,
        edits: {
          resize: {
            width: width,
            height: height,
            fit: 'cover'
          }
        }
      )
    )
  end

  def self.get_image_for_tooltip(element)

    if (element.class == Recipe)
      return [
        'https://d34nm4jmyicdxh.cloudfront.net/' + image_path(element.image_with_backup, 300, 200),
        'https://d34nm4jmyicdxh.cloudfront.net/' + image_path(element.image_with_backup, 600, 400)
      ]
    elsif ((element.class == Component || element.class == Subcomponent) && element.illustration.present?)
      return [
        'https://d34nm4jmyicdxh.cloudfront.net/' + image_path(element.illustration, 300, 300),
        'https://d34nm4jmyicdxh.cloudfront.net/' + image_path(element.illustration, 600, 600)
      ]
    else
      return nil
    end
  end

  def self.tooltip(element)
    return nil if (element.class == Component && !element.illustration.present?) 
    subtitle = element.try(:subtitle).present? ? "<div class='tooltip__description'>#{element.subtitle}</div>" : ''
    images = get_image_for_tooltip(element)
    name = element.class == Subcomponent ? element.component.name : element.name
    return nil if !images.present?

    "<div class='tooltip tooltip--#{element.class.to_s.downcase}'>"\
      "<img class='tooltip__image' src='#{images[0]}' srcset='#{images[0]} 1x, #{images[1]} 2x'/>"\
      "<div class='tooltip__title'>#{name}</div>"\
      "#{subtitle}"\
      "<svg class='tooltip__tip'><use href='/dist/sprite.svg#tooltip-tip-white'></use></svg>"\
    '</div>'
  end

  def self.model_for_symbol(symbol)
    {
      ':' => Component,
      '=' => Recipe,
      '::' => Subcomponent
    }[symbol]
  end

  def self.convert_links_in_place(md)
    return '' unless md.present?

    md.gsub(/(\=|\:\:|\:|\#)\[(.*?)\]/) do |*|
      element = model_for_symbol(Regexp.last_match(1)).where('lower(name) = ?', Regexp.last_match(2).downcase).first
      # for in-recipe subcomponents (:)
      if Regexp.last_match(1) == ':'
        subcomponent = Subcomponent.where('lower(name) = ?', Regexp.last_match(2).downcase).first
        element = subcomponent if subcomponent.present?
      end

      # for in-component subcomponents (::)
      if element.present? && element.class.to_s == 'Subcomponent' && Regexp.last_match(1) == '::'
        match = Regexp.last_match(2)
        count = Subcomponent.find_by_name(match).try(:list_elements).try(:count) || 0
        slug = ApplicationHelper.slugify(match)
        "<h2 id='#{slug}' class='subcomponent'>#{match} • <a href='#table' data-table-link='#{ERB::Util.u(match)}'>#{count} recipes »</a></h2>"
      elsif element && (element.class == Recipe || element.class == Component || element.class == Subcomponent)

        tt = tooltip(element)
        if (tt.present?)
          "<a href=\"#{element.url}\" tooltip=\"#{CGI.escapeHTML(tt)}\">#{Regexp.last_match(2)}</a>"
        else
          "<a href=\"#{element.url}\">#{Regexp.last_match(2)}</a>"
        end
      elsif element
        "<a href=\"#{element.url}\">#{Regexp.last_match(2)}</a>"
      else
        Regexp.last_match(2)
      end
    end
  end

  def self.convert_recommended_bottles_in_place(md)
    return '' unless md.present?

    md.gsub(/(\&)\[(.*?)\]/) do |*|
      "<div class='recommended-bottles'>#{Regexp.last_match(2).gsub(/(\$+)/, '<em>\1</em>')}</div>"
    end
  end

  def self.convert_subcomponent_recipe(md)
    md.gsub!(/^\* (.*?\n)/) do |*|
      CustomMarkdown.consruct_recipe_line(Regexp.last_match(1))
    end
  end

  def self.convert_subcomponent_recipes_in_place(md)
    return '' unless md.present?

    md.gsub(/(\$)\[(.*?)\](.*?)(\$)\[end\]/m) do |*|
      "<div class='recipe subcomponent-recipe'>"\
        "<div class='subcomponent-recipe__label'>#{Regexp.last_match(2)}</div>"\
        "#{convert_subcomponent_recipe(Regexp.last_match(3))}"\
      '</div>'
    end
  end

  def self.remove_custom_links(md)
    return '' unless md.present?

    md.gsub(/(\=|\:|\:\:|\#|\&)\[(.*?)\]/) do |*|
      Regexp.last_match(2)
    end
  end

  def self.convert_fractions(str)
    str.gsub(/\d+.(\d+)/) do |match|
      case match
      when '2.75' then '2¾'
      when '2.5' then '2½'
      when '2.25' then '2¼'
      when '1.75' then '1¾'
      when '1.5' then '1½'
      when '1.25' then '1¼'
      when '0.75' then '¾'
      when '0.6' then '⅔'
      when '0.3' then '⅓'
      when '0.5' then '½'
      when '0.25' then '¼'
      when '0.125' then '⅛'
      else match
      end
    end.html_safe
  end

  def self.consruct_recipe_line(md)
    regex = /([0-9]*\.?[0-9]*)(oz|tsp|tbsp|Tbsp|dash|dashes|lb|lbs|cup|cups)?(.*?)$/
    search = md.match(regex).to_a.drop(1) # first is complete match

    if !search[0] || search[0].empty? || search[0].blank?
      return "* <span class='amount'></span><span class='ingredient'>#{md}</span>\n"
    end

    unit = search[1] ? "<span class='unit'>#{search[1]}</span>" : ''
    "* <span class='amount'>#{convert_fractions(search[0])}#{unit}</span><span class='divider'></span><span class='ingredient'>#{search[2]}</span>\n"
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
    index = 0
    md.scan(/\:\:\[(.*?)\]/) do
      element =
        Subcomponent.find_by_name(Regexp.last_match(1)) ||
        Subcomponent.create(name: Regexp.last_match(1).downcase, component_id: instance.id)
      element.update_attribute(:index, index)
      index += 1
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
