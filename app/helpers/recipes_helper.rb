module RecipesHelper

  def undefined
    @recipe.id.nil?
  end

  def form_action
    undefined ? "create" : "update"
  end

  def edit_url
    @recipe.edit_url
  end

  def default_text(text_for)
    undefined ? "" : @recipe[text_for]
  end

  def submit_text
    undefined ? "create" : "update"
  end
  
  def recipes_cache_key
    generic_cache_key(@recipe, "show")
  end
end