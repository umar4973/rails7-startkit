# rails g model Article
#  title:string
#  content_raw:text
#  content:text
#  status:string

# rake db:migrate
#
class Article < ApplicationRecord
  # ElasticSearch / Chewy
  update_index('articles') { self }

  # Kaminari. Pagination
  paginates_per 3

  # rails runner Article.get_currency
  def self.get_currency
    url = "https://api.exchangerate.host/latest?base=USD&symbols=KGS"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    response_obj = JSON.parse(response)
    puts "[#{DateTime.now.strftime('%d.%m.%Y %H.%M.%S')}]: " + \
         "USD:KGS currency rate: " + response_obj['rates']['KGS'].to_s
  end

  # Take a raw content from a user and save it in `content_raw`.
  # But never render `content_raw` on a page. It is dangerous!
  # Process a content once `on save` and cut off dangerous tags.
  # Now you can render `content` field on a page with using `raw` helper
  # <%= raw article.content %>
  before_save :prepare_content

  # https://www.ruby-toolbox.com/projects/sanitize
  def prepare_content
    self.title = Sanitize.fragment(title, { elements: [] }).strip
    self.content = Sanitize.fragment(content_raw, Sanitize::Config::RESTRICTED).strip
  end
end
