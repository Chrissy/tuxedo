require 'recipe.rb'

class Component < ActiveRecord::Base
  serialize :recipes, Array

  def url
    "/components/#{id}"
  end

  def link
    "<a href='#{url}' class='component'>#{name}</a>"
  end

end