# frozen_string_literal: true

module Livecal
  class Calendar
    include Enumerable

    attr_reader :events

    def initialize(events)
      @events = events
    end

    def each(&block)
      events.each(&block)
    end
  end
end
