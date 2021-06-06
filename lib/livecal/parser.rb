# frozen_string_literal: true

require_relative "./calendar"
require_relative "./event"
require_relative "./recurring_events"

module Livecal
  class Parser
    def self.call(...)
      new(...).call
    end

    def initialize(calendar_source, from:, to:)
      @calendar_source = calendar_source
      @from = from
      @to = to
    end

    def call
      Calendar.new(events.collect { |event| Event.from_ical(event) })
    end

    private

    attr_reader :calendar_source, :from, :to

    def events
      (
        standalone_events + recurring_events + recurring_changes
      ).sort_by(&:dtstart)
    end

    def recurring_changes
      within_window(calendar_source.recurring_changes)
    end

    def recurring_events
      calendar_source
        .recurring_events
        .collect { |event| instances(event) }
        .flatten
    end

    def instances(event)
      RecurringEvents.call(
        event,
        from: from,
        to: to,
        changes: recurring_changes
      )
    end

    def standalone_events
      within_window(calendar_source.standalone_events)
    end

    def within_window(events)
      events.select { |event| event.dtstart >= from && event.dtstart <= to }
    end
  end
end
