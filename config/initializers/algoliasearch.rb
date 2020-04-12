# frozen_string_literal: true

AlgoliaSearch.configuration = {
  application_id: 'LD61RF5HKX',
  api_key: ENV['ALGOLIA_KEY'],
  connect_timeout: 2,
  receive_timeout: 30,
  send_timeout: 30,
  batch_timeout: 120,
  search_timeout: 5
}
