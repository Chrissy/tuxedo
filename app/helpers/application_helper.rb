# frozen_string_literal: true

require 'base64'

module ApplicationHelper
  def delete_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: 'delete', id: object.id
  end

  def new_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: 'new', id: object.id
  end

  def publish_status(element)
    '| ✓' if element.published? && element.is_a?(Recipe)
  end

  def links
    List.find_by_name('Links') || List.new
  end

  def all_elements_for_autocomplete
    elements = []
    elements
      .concat(Recipe.all_for_display)
      .concat(List.all_for_display)
      .concat(Component.all_for_display)
  end

  def no_index
    @recipe && !@recipe.published?
  end

  def all_elements_for_search
    text_search(params[:query]).with_highlights
  end

  def slugify(string)
    string.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

  def self.slugify(string)
    string.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

  def base_spirits
    [
      Component.find_by_name('rum'),
      Component.find_by_name('cognac'),
      Component.find_by_name('rye'),
      Component.find_by_name('gin'),
      Component.find_by_name('reposado tequila')
    ]
  end

  def swash(text)
    letter = text[0]
    "<span class='swash-cap letter-#{letter.downcase}'>#{letter.upcase}</span>#{text[1..-1]}".html_safe
  end

  def image_sizes(size)
    {
      'xxlarge2x' => { width: 1540, height: 1300 },
      'xxlarge' => { width: 770, height: 650 },
      'xlarge2x' => { width: 1200, height: 1200 },
      'xlarge' => { width: 600, height: 600 },
      'large2x' => { width: 1120, height: 820 },
      'large' => { width: 560, height: 410 },
      'medium2x' => { width: 600, height: 400 },
      'medium' => { width: 300, height: 200 },
      'small2x' => { width: 200, height: 200 },
      'small' => { width: 100, height: 100 },
      'pinterest' => { width: 476, height: 666 },
      'illustration' => { width: 275, height: 275 },
      'illustration2x' => { width: 550, height: 550 }
    }[size.to_s]
  end

  def image_resize(size)
    {
      resize: {
        width: size[:width],
        height: size[:height],
        fit: 'cover'
      }
    }
  end

  def image_path(size, image)
    Base64.strict_encode64(
      JSON.generate(
        bucket: 'chrissy-tuxedo-no2',
        key: image,
        edits: image_resize(size)
      )
    )
  end

  def image_url(element, size, method = :image_with_backup)
    size_hash = image_sizes(size)
    'https://d34nm4jmyicdxh.cloudfront.net/' + image_path(size_hash, element.send(method))
  end

  def header_image(element, class_name = '', hero = false, carousel = false)
    options = {
      srcset: [
        image_url(element, hero ? :xxlarge : :xlarge) + ' 1x',
        image_url(element, hero ? :xxlarge2x : :xlarge2x) + ' 2x'
      ].join(', '),
      class: class_name,
      alt: "#{element.name} cocktail photo",
      itemprop: 'image',
      "data-pin-media": pinnable_image_url(element),
      "data-pin-url": pin_url(element),
      "data-pin-description": element.name
    }

    options['data-carousel-index'] = 1 if carousel

    image_tag(
      image_url(element, hero ? :xxlarge : :xlarge),
      options
    )
  end

  def list_image(element, class_name = '', method = :image_with_backup, carousel_index = nil)
    options = {
      srcset: [image_url(element, :large, method) + ' 1x', image_url(element, :large2x, method) + ' 2x'].join(', '),
      alt: "#{element.name} cocktail photo",
      itemprop: 'image',
      class: class_name || 'list-element__img',
      "data-pin-media": pinnable_image_url(element, method),
      "data-pin-url": pin_url(element),
      "data-pin-description": element.name
    }

    options['data-carousel-index'] = carousel_index if carousel_index

    image_tag(
      image_url(element, :large, method),
      options
    )
  end

  def ingredient_card_image(element, class_name, method = :image_with_backup)
    image_tag(
      image_url(element, :medium, method),
      srcset: [image_url(element, :medium, method) + ' 1x', image_url(element, :medium2x, method) + ' 2x'].join(', '),
      class: class_name,
      alt: "#{element.name} cocktail photo",
      itemprop: 'image'
    )
  end

  def illustration_image(element, class_name)
    image_tag(
      image_url(element, :illustration, :illustration),
      srcset: [image_url(element, :illustration2x, :illustration) + ' 1x', image_url(element, :illustration2x, :illustration) + ' 2x'].join(', '),
      class: class_name,
      alt: "#{element.name} botanical drawing",
      itemprop: 'image'
    )
  end

  def index_image(element)
    image_tag(
      image_url(element, :small),
      srcset: [image_url(element, :small) + ' 1x', image_url(element, :small2x) + ' 2x'].join(', '),
      class: 'index-element__img',
      alt: "#{element.name} cocktail photo",
      itemprop: 'image'
    )
  end

  def pinnable_image_url(element, method = :image_with_backup)
    image_url(element, :pinterest, method)
  end

  def landscape_social_image_url(element)
    image_url(element, :small)
  end

  def index_header_image
    image_tag 'index-image.png', class: 'header-image', alt: 'cocktail index image'
  end

  def pin_url(element)
    request.protocol + request.host_with_port + element.url
  end

  def tooltip(element)
    "<div class='tooltip'>
      #{ingredient_card_image(element, 'tooltip__image')}
      <div class='tooltip__title'>#{element.name}</div>
      #{if element.try(:subtitle).present?
          "<div class='tooltip__description'>#{element.subtitle}</div>"
        end}
      <svg class='tooltip__tip'><use href='dist/sprite.svg#tooltip-tip-white'></use></svg>
    </div>"
  end

  def text_tooltip(text)
    "<div class='tooltip tooltip--text'>
      <div class='tooltip__title tooltip__title--center'>#{text}</div>
      <svg class='tooltip__tip'><use href='dist/sprite.svg#tooltip-tip-white'></use></svg>
    </div>"
  end

  def list_id
    @list.id if defined? @list
  end

  def display_number_with_fallback(element, class_name = '')
    if element.try(:number)
      render 'shared/display_number', number: element.number + 1, class_name: class_name
    else
      ''
    end
  end

  def cache_key(object, view)
    updated_at = object.try(:updated_at).try(:to_s, :number)
    "#{object.class.to_s.pluralize.downcase}/#{view}-#{object.id}-#{updated_at}"
  end

  def global_header_cache_key
    cache_key(links, 'global-header')
  end

  def meta_cache_key
    layout_object = @layout_object.present? ? @layout_object : List.find(1)
    cache_key(layout_object, 'meta')
  end

  def index_key_from_set(elements)
    if elements.empty?
      'empty'
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
    'Tuxedo No.2 | A Cocktail Companion'
  end

  def meta_description
    markdown_as_text(@layout_object.try(:description_to_html).try(:truncate, 250) || default_description)
  end

  def markdown_as_text(markdown)
    raw(strip_tags(markdown))
  end

  def default_description
    'Your drinking guide with cocktail recipes by spirit, ingredient, and season'
  end

  def meta_image
    pinnable_image_url(@layout_object) if @layout_object
  end

  def twitter_image
    landscape_social_image_url(@layout_object) if @layout_object
  end

  def similar_recipes_link(recipe)
    first_component = recipe.components.first
    if first_component
      link_to "other #{first_component.nickname} drinks".titleize, first_component.url
    end
  end

  def all_recipes_link
    everything_link = List.find_by_name('Everything').try(:url) || '/'
    link_to 'All Cocktails', everything_link
  end

  def clear_image_button(element)
    link_to '(clear)', '#', class: 'clear_image' if element.image.present?
  end
end
