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
end
