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

  def test_remove_custom_links
    sample_markdown = "two dashes of :[rye], one dash of :[gin]"
    markdown = CustomMarkdown.remove_custom_links(sample_markdown)
    assert markdown = "two dashes of rye, one dash of gin"
  end
end
