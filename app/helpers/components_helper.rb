module ComponentsHelper

  def form_action
    @component.present? ? "update" : "create"
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
  
  def components_cache_key(component)
    generic_cache_key(component, "component")
  end 
end