require 'recipe.rb'
require 'component.rb'
require 'list.rb'

## to reindex, you will need to specify the environment likely:
## rake searchkick:reindex CLASS=List RAILS_ENV=development
## rake searchkick:reindex CLASS=Component RAILS_ENV=development
## rake searchkick:reindex CLASS=Recipe RAILS_ENV=development
## You should only need to reindex when launching a new instance
## If you want to work locally, just make sure elasticsearch is
## running and comment out the stuff below

if ENV['RAILS_ENV'] == 'development'
  ENV["ELASTICSEARCH_URL"] = "https://search-tux-development-2-tsg6khhvvu37wbll5xibie5m6q.us-east-1.es.amazonaws.com:443"
else
  ENV["ELASTICSEARCH_URL"] = "https://search-tux-production-u5ezbg7brsrsmpm3ml2rcv7p7i.us-east-1.es.amazonaws.com:443"
end

Searchkick.aws_credentials = {
  access_key_id: ENV['S3_KEY'],
  secret_access_key: ENV['S3_SECRET'],
  region: 'us-east-1'
}

