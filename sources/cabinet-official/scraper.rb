#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      parts[1].tidy
    end

    def position
      parts[0].tidy
    end

    private

    def parts
      noko.text.tidy.split(/(?<=minister)/)
    end
  end

  class Members
    def member_container
      noko.css('a.list-group-item').select { |node| node.text.to_s.include? 'minister' }
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv if file.exist? && !file.empty?
