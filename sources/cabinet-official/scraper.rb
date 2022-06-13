#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      noko.text.tidy
    end

    def position
      noko.xpath('following-sibling::p[1]').text.tidy
    end
  end

  class Members
    def members
      super + pm_container.map { |member| fragment(member => Member).to_h }
    end

    private

    def member_container
      # TODO: find the most recent accordion and restrict to that
      noko.css('#alates-3062022--accordion .list-with-image-vp .font-weight-bold')
    end

    def pm_container
      noko.css('.col-xl-8 .mb-3 h3')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv if file.exist? && !file.empty?
