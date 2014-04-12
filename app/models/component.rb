class Component < ActiveRecord::Base

def url
  "/components/#{id}"
end

def link
  "<a href='#{url}' class='component'>#{name}</a>"
end

end