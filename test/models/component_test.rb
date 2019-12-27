require 'test_helper'
require 'custom_markdown'
 
class ComponentTest < ActiveSupport::TestCase
  def test_description_to_html
    testComponent = Component.find(1)
    description = testComponent.description_to_html
    assert description == "<p>has subcomponent <h2><a href='/ingredients/gin'>old tom</a></h2> with some <a href='/ingredients/rye'>rye</a></p>\n"
  end

  def test_description_to_plain_text
    testComponent = Component.find(1)
    description = testComponent.description_as_plain_text
    assert description == "has subcomponent old tom with some rye\n"
  end

  def test_description_updates
    testComponent = Component.find(1)
    testComponent.update_attribute(:description, "this is some :[gin]")
    testComponent.save!
    assert testComponent.description == "this is some :[gin]"
  end
end
