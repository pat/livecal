# frozen_string_literal: true

require "delegate"

module Livecal
  class Event < SimpleDelegator
    def self.from_ical(source)
      new(source)
    end

    def starts_at
      dtstart
    end

    def ends_at
      dtend
    end
  end
end
