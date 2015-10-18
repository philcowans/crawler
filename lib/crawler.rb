require './lib/sitemap'

require 'nokogiri'
require 'open-uri'
require 'set'

class Crawler
  def crawl(initial_uri, logger, options)
    @logger = logger
    @domain = initial_uri.host
    @crawl_queue = [initial_uri.to_s]
    @sitemap = Sitemap.new
    @options = options

    download_and_parse_uri(URI.parse(@crawl_queue.pop)) until @crawl_queue.empty? or (options.has_key?(:limit) and @sitemap.keys.size > @options[:limit])

    @sitemap
  end

  private

  def download_and_parse_uri(uri)
    @logger.info "Parsing: #{uri.inspect}"
    @sitemap[string_for_comparison(uri)] = Set.new
    doc = Nokogiri::HTML(open(uri.to_s))
    if @options[:hyperlinks_only]
      tag_types = [['a', 'href']]
    else
      tag_types = [['a', 'href'], ['img', 'src'], ['link', 'href']]
    end
    tag_types.each do |tag_type|
      doc.css(tag_type[0]).each do |link|
        begin
          target_uri = URI.join(uri.to_s, link.attributes[tag_type[1]].to_s)
          next unless target_uri.scheme == 'http' or target_uri.scheme == 'https'
          unless @sitemap.has_key?(string_for_comparison(target_uri))
            @sitemap[string_for_comparison(uri)].add(string_for_comparison(target_uri)) unless target_uri.host != @domain and @options[:domain_only]
            @crawl_queue.push(string_for_comparison(target_uri)) unless target_uri.host != @domain or @crawl_queue.include?(string_for_comparison(target_uri))
          end
        rescue URI::InvalidURIError
          @logger.warn 'Ingnoring unparsable URI'
        end
      end
    end
   end

  def string_for_comparison(uri)
    s = uri.scheme + '://' + uri.host + uri.path
    s += '?' + uri.query unless uri.query.nil?
    s
  end
end
