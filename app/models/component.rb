class Component < ActiveRecord::Base

def url
  "/components/#{id}"
end

def link
  "<a href='#{url}'>#{name}</a>"
end

end