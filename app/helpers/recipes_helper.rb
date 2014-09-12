module RecipesHelper

  def undefined
    @recipe.id.nil?
  end
  
  def all_elements_for_search
    elements = []
    elements.concat(Recipe.all).concat(List.all_for_display).concat(Component.all)
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
end