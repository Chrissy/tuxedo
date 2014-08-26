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
      w: 705, 
      h: 405, 
      fit: 'crop'
    }
    filepicker_image_tag(image_with_backup(element.image), opts, class: "header-image", :"data-resize"=>"2.5")
  end
  
  def list_image(element)
    filepicker_image_tag(image_with_backup(element.image), w: 950, h: 650, fit: 'crop', align: "center,center")
  end
end
