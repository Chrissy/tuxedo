module ApplicationHelper

  def delete_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: "delete", id: object.id
  end

  def new_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: "new", id: object.id
  end
  
  def publish_status(element)
    "✓" if element.published?
  end
  
  def links
    List.find_by_name("Links") || List.new
  end
  
  def swash(text)
    "<span class='swash-cap'>#{text[0].upcase}</span>#{text[1..-1]}".html_safe
  end
  
  def header_image(element)
    opts = {
      w: 500, 
      h: 287, 
      fit: 'crop',
      cache: 'true'
    }
    filepicker_image_tag(element.image_with_backup, opts, class: "header-image", :"data-resize"=>"3", :itemprop => "image")
  end
  
  def list_image(element)
    opts = {
      w: 320, 
      h: 225, 
      fit: 'crop',
      cache: 'true'
    }
    filepicker_image_tag(element.image_with_backup, opts, :"data-resize" => "3")
  end
  
  def list_id
    @list.id if defined? @list
  end
  
  def display_number_with_fallback(element)
    if element.try(:number)
      render "shared/display_number", :number => element.number
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
  
  def site_title
    @layout_object.try(:tagline) || meta_title
  end
  
  def meta_title
    "Tuxedo No.2 | A Stately Cocktail Companion"
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
    @layout_object.try(:image_with_backup)
  end
  
  def similar_recipes_link(recipe)
    first_component = recipe.components.first
    link_to "other #{first_component.nick} drinks".titleize, first_component.url 
  end
  
  def all_recipes_link
    everything_link = List.find_by_name("Everything").try(:url) || "/" 
    link_to "All Cocktails", everything_link
  end
  
  def clear_image_button(element)
    link_to '(clear)', "#", :class => 'clear_image' if element.image.present?
  end
end
