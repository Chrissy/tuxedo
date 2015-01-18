module ComponentsHelper
  
  def undefined
    @component.id.nil?
  end

  def form_action
    undefined ? "create" : "update"
  end
  
  def aka_options
    Component.all.sort_by(&:name).map{|c|[c.name,c.id]}.unshift(["none",""])
  end

  def edit_url
    @component.edit_url
  end

  def default_text(text_for)
    @component.present? ? @component[text_for] : ""
  end

  def submit_text
    undefined ? "create" : "update"
  end
end