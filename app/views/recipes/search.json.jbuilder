json.cache!(search_cache_key) do
  json.array! all_elements_for_search do |element|
    json.val element.name
    json.url element.url
  end
end