#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  section = noko.xpath('//h4[contains(span,"Candidates elected")]/following-sibling::table[1]//tr[td]').each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[2].text.tidy,
      wikiname: tds[2].xpath('.//a[not(@class="new")]/@title').text.tidy,
      area: tds[0].text.tidy,
      party: tds[3].text.tidy,
    }
    ScraperWiki.save_sqlite([:name, :area, :party], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/Costa_Rican_general_election,_2014')
