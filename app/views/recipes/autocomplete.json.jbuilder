json.cache!("autocomplete", :expires_in => 1.hour) do
  json.array! all_elements_for_autocomplete do |element|
    json.label element.name
    json.value element.url
  end
end
