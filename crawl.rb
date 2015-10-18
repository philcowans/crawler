#!/usr/bin/env ruby

require './lib/crawler'
require './lib/sitemap'

require 'logger'
require 'uri'

initial_uri = URI(ARGV[0])

crawler = Crawler.new
sitemap = crawler.crawl(initial_uri, Logger.new(STDERR), ARGV[1] && ARGV[1].to_i)
puts sitemap.to_dot
