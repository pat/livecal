# frozen_string_literal: true

require "icalendar"
require "net/http"
require "uri"

module Livecal
  class CalendarSource
    def self.from_url(url)
      from_string(Net::HTTP.get(URI(url)))
    end

    def self.from_file(path)
      from_string(File.read(path))
    end

    def self.from_string(contents)
      Icalendar::Calendar.parse(contents).collect { |source| new(source) }
    end

    def initialize(source)
      @source = source
    end

    def recurring_changes
      events.select { |event| event.rrule.empty? && event.recurrence_id }
    end

    def recurring_events
      events.select { |event| event.rrule.any? }
    end

    def standalone_events
      events.select { |event| event.rrule.empty? && event.recurrence_id.nil? }
    end

    private

    attr_reader :source

    def events
      source.events
    end
  end
end
