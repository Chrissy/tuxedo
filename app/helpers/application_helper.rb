module ApplicationHelper

  def delete_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: "delete", id: object.id
  end

  def new_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: "new", id: object.id
  end

  def publish_status(element)
    "| ✓" if element.published? && element.is_a?(Recipe)
  end

  def links
    List.find_by_name("Links") || List.new
  end

  def all_elements_for_autocomplete
    elements = []
    elements.concat(Recipe.all_for_display).concat(List.all_for_display).concat(Component.all_for_display)
  end

  def text_search(query)
    Searchkick.search query, fields: ["name^10", :description, :recipe], highlight: {fields: {description: {fragment_size: 100}, recipe: {fragment_size: 50}}}
  end

  def all_elements_for_search
    text_search(params[:query]).with_highlights
  end

  def swash(text)
    letter = text[0]
    "<span class='swash-cap letter-#{letter.downcase}'>#{letter.upcase}</span>#{text[1..-1]}".html_safe
  end

  def image_url(element, size)
    image_env = JSON.load(File.read('images.json'))
    return image_env["bucket"] + image_env["sizes"][size.to_s] + element.image_with_backup
  end

  def header_image(element)
    image_tag(
      image_url(element, :mediumCover),
      class: "header-image",
      alt: "#{element.name} cocktail photo",
      :"data-lazy-load"=> image_url(element, :largeCover),
      :itemprop => "image",
      :"data-dont-compress" => element.try(:dont_compress_image),
      :"data-pin-media" => pinnable_image_url(element),
      :"data-pin-url" => pin_url(element),
      :"data-pin-description" => element.name)
  end

  def list_image(element)
    image_tag(
      image_url(element, :list),
      alt: "#{element.name} cocktail photo",
      :itemprop => "image",
      :"data-pin-media" => pinnable_image_url(element),
      :"data-pin-url" => pin_url(element),
      :"data-pin-description" => element.name)
  end

  def index_image(element)
    image_tag(
      image_url(element, :thumb),
      class: "element-image small",
      alt: "#{element.name} cocktail photo",
      itemprop: "image")
  end

  def pinnable_image_url(element)
    image_url(element, :pinterest)
  end

  def landscape_social_image_url(element)
    image_url(element, :list)
  end

  def index_header_image
    image_tag 'index-image.png', class: "header-image", alt: "cocktail index image"
  end

  def pin_url(element)
    request.protocol + request.host_with_port + element.url
  end

  def list_id
    @list.id if defined? @list
  end

  def display_number_with_fallback(element)
    if element.try(:number)
      render "shared/display_number", :number => element.number + 1
    else
      "<div class='decoration'></div>".html_safe
    end
  end

  def cache_key(object, view)
    updated_at = object.try(:updated_at).try(:to_s, :number)
    "#{object.class.to_s.pluralize.downcase}/#{view}-#{object.id}-#{updated_at}"
  end

  def global_header_cache_key
    cache_key(links, "global-header")
  end

  def meta_cache_key
    layout_object = @layout_object.present? ? @layout_object : List.find(1)
    cache_key(layout_object, "meta")
  end

  def index_key_from_set(elements)
    if elements.empty?
      "empty"
    else
      elements.max_by(&:updated_at).updated_at.try(:utc).try(:to_s, :number)
    end
  end

  def index_cache_key(elements, model)
    "#{model.to_s.pluralize.downcase}/index-#{index_key_from_set(elements)}"
  end

  def index_letter_cache_key(elements, model, letter)
    "#{model.to_s.pluralize.downcase}/#{letter}-index-#{index_key_from_set(elements)}"
  end

  def global_index_cache_key(elements)
    "index-#{index_key_from_set(elements)}"
  end

  def site_title
    @layout_object.try(:tagline) || meta_title
  end

  def meta_title
    "Tuxedo No.2 | A Cocktail Companion"
  end

  def meta_description
    markdown_as_text(@layout_object.try(:description_to_html).try(:truncate, 250) || default_description)
  end

  def markdown_as_text(markdown)
    raw(strip_tags(markdown))
  end

  def default_description
    "Your drinking guide with cocktail recipes by spirit, ingredient, and season"
  end

  def meta_image
    pinnable_image_url(@layout_object) if @layout_object
  end

  def twitter_image
    landscape_social_image_url(@layout_object) if @layout_object
  end

  def similar_recipes_link(recipe)
    first_component = recipe.components.first
    link_to "other #{first_component.nickname} drinks".titleize, first_component.url if first_component
  end

  def all_recipes_link
    everything_link = List.find_by_name("Everything").try(:url) || "/"
    link_to "All Cocktails", everything_link
  end

  def clear_image_button(element)
    link_to '(clear)', "#", :class => 'clear_image' if element.image.present?
  end

  def index_item_class_name(element)
    "#{element.class.to_s.downcase}_admin_element"
  end
end
