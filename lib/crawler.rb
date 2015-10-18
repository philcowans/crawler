require 'nokogiri'
require 'open-uri'
require 'set'

class Crawler
  def crawl(initial_uri)
    @crawl_queue = [initial_uri]
    @sitemap = {}
    download_and_parse_uri(@crawl_queue.pop)
    @sitemap
  end

  private

  def download_and_parse_uri(uri)
    doc = Nokogiri::HTML(open(uri.to_s))
    doc.css('a').each do |link|
      begin
        target_uri = URI.join(uri.to_s, link.attributes['href'].to_s)
        puts target_uri.to_s
      rescue URI::InvalidURIError
        puts 'Ingnoring unparsable URI'
      end
    end
  end
end
