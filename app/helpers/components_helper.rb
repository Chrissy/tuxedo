module ComponentsHelper

  def form_action
    @component.present? ? "update" : "create"
  end
  
  def aka_options
    Component.all.sort_by!(&:name).map{|c|[c.name,c.id]}.unshift(["none","0"])
  end

  def edit_url
    @component.edit_url
  end

  def default_text(text_for)
    @component.present? ? @component[text_for] : ""
  end

  def submit_text
    @component.present? ? "update" : "create"
  end
end