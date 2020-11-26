require 'test_helper'
require 'custom_markdown'
 
class RecipeTest < ActiveSupport::TestCase
  def test_converts_markdown_in_place
    sample_markdown = "two dashes of :[rye], one dash of :[gin]"
    converted_description = CustomMarkdown.convert_links_in_place(sample_markdown)
    assert converted_description == "two dashes of <a href=\"/ingredients/rye\">rye</a>, one dash of <a href=\"/ingredients/gin\">gin</a>"
  end

  def test_description_to_html
    testRecipe = Recipe.find(1)
    description = testRecipe.description_to_html 
    assert description == "<p>two dashes of <a href=\"/ingredients/rye\">rye</a>, one dash of <a href=\"/ingredients/gin\">gin</a></p>\n"
  end

  def test_description_updates
    testRecipe = Recipe.find(1)
    testRecipe.update_attribute(:description, "one dash :[gin]")
    testRecipe.save!
    assert testRecipe.description == "one dash :[gin]"
  end

  def test_recipe_updates
    testRecipe = Recipe.find(1)
    testRecipe.update_attribute(:recipe, "one dash :[gin]")
    testRecipe.save!
    assert testRecipe.recipe == "one dash :[gin]"
  end

  def test_creates_relationships
    testRecipe = Recipe.find(1)
    testRecipe.update_attribute(:recipe, "one dash :[gin]")
    assert Relationship.first.child.id == Component.find_by_name("gin").id
  end

  def test_converts_recipe_to_html
    testRecipe = Recipe.find(1)
    testRecipe.update_attribute(:recipe, "one dash :[gin]")
    assert testRecipe.convert_recipe_to_html == "<p>one dash <a href=\"/ingredients/gin\">gin</a></p>\n"
  end

  def test_adds_tags
    testRecipe = Recipe.find(1)
    testRecipe.update_attribute(:tags_as_text, "classic, Coupe, cracked ice")
    assert testRecipe.tag_list.length == 3
    assert testRecipe.tag_list.include?("classic")
    assert testRecipe.tag_list.include?("coupe")
    assert testRecipe.tag_list.include?("cracked ice")
  end
end
