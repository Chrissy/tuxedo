module ListsHelper

  def title
    @list.home? ? @list.elements.first.name : @list.name
  end

  def undefined
    @list.id.nil?
  end

  def form_action
    undefined ? "create" : "update"
  end

  def edit_url
    "/list/edit/#{@list.id}"
  end

  def default_text(text_for)
    undefined ? "" : @list[text_for]
  end

  def submit_text
    undefined ? "create" : "update"
  end
end