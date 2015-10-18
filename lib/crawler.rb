require './lib/sitemap'

require 'nokogiri'
require 'open-uri'
require 'set'

class Crawler
  def crawl(initial_uri, logger, options)
    @domain = initial_uri.host
    @logger = logger
    @options = options
    @sitemap = Sitemap.new

    @crawl_queue = [initial_uri.to_s]
    until @crawl_queue.empty? or (options.has_key?(:limit) and @sitemap.keys.size > @options[:limit])
      download_and_parse_uri(URI.parse(@crawl_queue.pop))
    end

    @sitemap
  end

  private

  def already_in_sitemap?(target_uri)
    @sitemap.has_key?(string_for_comparison(target_uri))
  end

  def download_and_parse_uri(uri)
    @logger.info "Parsing: #{uri.inspect}"
    @sitemap[string_for_comparison(uri)] = Set.new
    doc = Nokogiri::HTML(open(uri.to_s))
    tag_types.each do |tag_type|
      doc.css(tag_type[0]).each do |link|
        begin
          target_uri = URI.join(uri.to_s, link.attributes[tag_type[1]].to_s)
          next unless ['http', 'https'].include?(target_uri.scheme)
          unless already_in_sitemap?(target_uri)
            @sitemap[string_for_comparison(uri)].add(string_for_comparison(target_uri)) unless ignore_link?(target_uri)
            unless @crawl_queue.include?(string_for_comparison(target_uri))
              @crawl_queue.push(string_for_comparison(target_uri)) unless do_not_follow_link?(target_uri)
            end
          end
        rescue URI::InvalidURIError
          @logger.warn 'Ingnoring unparsable URI'
        end
      end
    end
  end

  def ignore_link?(target_uri)
    target_uri.host != @domain and @options[:domain_only]
  end

  def do_not_follow_link?(target_uri)
    target_uri.host != @domain
  end

  def string_for_comparison(uri)
    s = uri.scheme + '://' + uri.host + uri.path
    s += '?' + uri.query unless uri.query.nil?
    s
  end

  def tag_types
    if @options[:hyperlinks_only]
      [['a', 'href']]
    else
      [['a', 'href'], ['img', 'src'], ['link', 'href']]
    end
  end
end
