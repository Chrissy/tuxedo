module RecipesHelper

  def form_action
    @recipe.present? ? "update" : "create"
  end

  def edit_url
    "/edit/#{@recipe.id}"
  end

  def default_text(text_for)
    @recipe.present? ? @recipe[text_for] : ""
  end

  def submit_text
    @recipe.present? ? "update" : "create"
  end
end