require 'nokogiri'
require 'open-uri'
require 'set'

class Crawler
  def crawl(initial_uri)
    @domain = initial_uri.host
    @crawl_queue = [initial_uri]
    @sitemap = {}
    download_and_parse_uri(@crawl_queue.pop)
    puts "Sitemap: #{@sitemap[string_for_comparison(initial_uri)].inspect}"
    puts "Crawl queue: #{@crawl_queue.inspect}"
    @sitemap
  end

  private

  def download_and_parse_uri(uri)
    @sitemap[string_for_comparison(uri)] = Set.new
    doc = Nokogiri::HTML(open(uri.to_s))
    doc.css('a').each do |link|
      begin
        target_uri = URI.join(uri.to_s, link.attributes['href'].to_s)
        unless @sitemap.has_key?(string_for_comparison(target_uri))
          @sitemap[string_for_comparison(uri)].add(string_for_comparison(target_uri))
          unless target_uri.host != @domain or @crawl_queue.include?(string_for_comparison(target_uri))
            @crawl_queue.push(string_for_comparison(target_uri))
          end
        end
      rescue URI::InvalidURIError
        puts 'Ingnoring unparsable URI'
      end
    end
   end

  def string_for_comparison(uri)
    s = uri.scheme + '://' + uri.host + uri.path
    s += '?' + uri.query unless uri.query.nil?
    s
  end
end
