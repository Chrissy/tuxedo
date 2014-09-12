json.cache!("search", :expires_in => 1.hour) do
  json.array! all_elements_for_search do |element|
    json.val element.name
    json.url element.url
  end
end