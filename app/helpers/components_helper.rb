module ComponentsHelper

  def form_action
    @component.present? ? "update" : "create"
  end

  def edit_url
    "/components/edit/1"
  end

  def default_text(text_for)
    @component.present? ? @component[text_for] : ""
  end

  def submit_text
    @component.present? ? "update" : "create"
  end
end