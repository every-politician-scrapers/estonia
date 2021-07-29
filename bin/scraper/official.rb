#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  # details for an individual member
  class Member < Scraped::HTML
    field :name do
      noko.text.tidy
    end

    field :position do
      noko.xpath('following-sibling::p[1]').text.tidy
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      container.map { |member| fragment(member => Member).to_h } +
        pm_container.map { |member| fragment(member => Member).to_h }
    end

    private

    def container
      noko.css('.list-with-image-vp .font-weight-bold')
    end

    def pm_container
      noko.css('.col-xl-8 .mb-3 h3')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv

