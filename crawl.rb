#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'crawler'
require 'sitemap'

require 'logger'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: crawl.rb [options] <initial URI>'

  opts.on('-d', '--domain-only', 'Only list links within domain') do |d|
    options[:domain_only] = d
  end

  opts.on('-a', '--hyperlinks-only', 'Only list hyperlinks (ignore img and link targets)') do |a|
    options[:hyperlinks_only] = a
  end

  opts.on('-l', '--limit limit', Integer, 'Limit size of crawl') do |l|
    options[:limit] = l
  end
end.parse!

initial_uri = URI(ARGV[0])

crawler = Crawler.new
sitemap = crawler.crawl(initial_uri, Logger.new(STDERR), options)
puts sitemap.to_dot
