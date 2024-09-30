# frozen_string_literal: true

require "delegate"

module Livecal
  class Event < SimpleDelegator
    def self.from_ical(source)
      new(source)
    end

    def starts_at
      dtstart.to_time
    end

    def ends_at
      dtend.to_time
    end
  end
end
