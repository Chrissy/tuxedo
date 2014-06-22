json.array! @recipes do |recipe|
  json.val recipe.name
  json.url recipe.url
end