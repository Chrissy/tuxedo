require 'minitest/autorun'
require 'test_helper.rb'
require 'custom_markdown'

 
class CustomMarkdownTest < Minitest::Test
  def test_model_for_symbol
    assert CustomMarkdown.model_for_symbol(":") == Component
    assert CustomMarkdown.model_for_symbol("=") == Recipe
    assert CustomMarkdown.model_for_symbol("#") == List
  end

  def test_converts_links_in_place
    # this is just a smoke test, db-based assertions should be in models
    sample_markdown = "two dashes of :[rye], one dash of :[gin]"
    markdown = CustomMarkdown.convert_links_in_place(sample_markdown)
    assert markdown = "two dashes of rye, one dash of gin"
  end

  def test_converts_recommended_bottles
    sample_markdown = "here is some &[gin, campari, and nonino]"
    markdown = CustomMarkdown.convert_recommended_bottles_in_place(sample_markdown)
    assert markdown = "here is some <div class='recommended-bottles'>gin, campari, and nonino</div>"
  end

  def test_remove_custom_links
    sample_markdown = "two dashes of :[rye], one dash of =[gin], one more &[fun], one =[even]"
    markdown = CustomMarkdown.remove_custom_links(sample_markdown)
    assert markdown = "two dashes of rye, one dash of gin, one more fun, one even"
  end

  def test_subcomponents_from_markdown
    sample_markdown = "
    here is some text.
    ::[old tom]
    more fun for :[you]
    ::[london dry]
    even more :[fun]
    ::[old tom]
    even more :[fun]
    "
    ingredient = Component.find(1)
    subcomponents = CustomMarkdown.subcomponents_from_markdown(ingredient, sample_markdown)
    assert subcomponents.length == 2
    assert subcomponents.map(&:name).include?("old tom")
    assert subcomponents.map(&:component).include?(ingredient)
    assert subcomponents[0].component.subcomponents.include?(subcomponents[0])
  end
end
