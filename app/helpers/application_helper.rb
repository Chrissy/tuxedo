module ApplicationHelper

  def delete_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: "delete", id: object.id
  end

  def new_link(object)
    url_for controller: object.class.to_s.pluralize.downcase, action: "new", id: object.id
  end
  
  def links
    List.find_by_name("Links") || List.new
  end
  
  def swash(text)
    "<span class='swash-cap'>#{text[0].upcase}</span>#{text[1..-1]}".html_safe
  end
  
  def image_with_backup(image)
    image.present? ? image : Recipe.first.image #probably should come up with a default image lol
  end
  
  def header_image(element)
    opts = {
      w: 500, 
      h: 287, 
      fit: 'crop',
      cache: 'true'
    }
    filepicker_image_tag(image_with_backup(element.image), opts, class: "header-image", :"data-resize"=>"3")
  end
  
  def list_image(element)
    opts = {
      w: 320, 
      h: 225, 
      fit: 'crop',
      cache: 'true'
    }
    filepicker_image_tag(image_with_backup(element.image), opts, :"data-resize" => "3")
  end
  
  def list_id
    @list.id if defined? @list
  end
  
  def generic_cache_key(object, view)
    updated_at = object.try(:updated_at).try(:to_s, :number)
    "#{object.class.to_s.pluralize.downcase}/#{view}-#{updated_at}"
  end
  
  def global_header_cache_key
    generic_cache_key(links, "global-header")
  end
end
