require 'nokogiri'
require 'open-uri'
require 'set'

class Crawler
  def crawl(initial_uri, limit = nil)
    @domain = initial_uri.host
    @crawl_queue = [initial_uri.to_s]
    @sitemap = {}
    download_and_parse_uri(URI.parse(@crawl_queue.pop)) until @crawl_queue.empty? or (limit and @sitemap.keys.size > limit)
    @sitemap
  end

  private

  def download_and_parse_uri(uri)
    puts "Parsing: #{uri.inspect}"
    @sitemap[string_for_comparison(uri)] = Set.new
    doc = Nokogiri::HTML(open(uri.to_s))
    doc.css('a').each do |link|
      begin
        target_uri = URI.join(uri.to_s, link.attributes['href'].to_s)
        next unless target_uri.scheme == 'http' or target_uri.scheme == 'https'
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
