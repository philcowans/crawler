#!/usr/bin/env ruby

require './lib/crawler'

require 'uri'

initial_uri = URI(ARGV[0])

crawler = Crawler.new
sitemap = crawler.crawl(initial_uri, ARGV[1] && ARGV[1].to_i)
