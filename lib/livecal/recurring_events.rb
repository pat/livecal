# frozen_string_literal: true

require "icalendar"
require "rrule"

module Livecal
  class RecurringEvents
    include Enumerable

    def self.call(...)
      new(...).to_a
    end

    def initialize(source, from:, to:, changes:)
      @source = source
      @from = from
      @to = to
      @changes = changes.select do |change|
        change.uid == source.uid && change.sequence >= source.sequence
      end
    end

    def each(&block)
      instances.each(&block)
    end

    private

    attr_reader :source, :from, :to, :changes

    def changed?(instance)
      changes.any? do |change|
        change.recurrence_id&.value_ical == instance.dtstart.value_ical
      end
    end

    def duration
      @duration ||= source.dtend.to_i - source.dtstart.to_i
    end

    def instance_with_start(time)
      source.dup.tap do |instance|
        instance.rrule = []
        instance.dtstart = time_in_zone(time)
        instance.dtend = time_in_zone(time + duration)
      end
    end

    def instances
      rrule
        .between(from, to)
        .collect { |start| instance_with_start(start) }
        .reject { |instance| changed?(instance) }
    end

    def rrule
      RRule::Rule.new(
        source.rrule.first.value_ical,
        dtstart: source.dtstart,
        exdate: source.exdate,
        tzid: tzid
      )
    end

    def time_in_zone(time)
      ::Icalendar::Values::DateTime.new(time, "tzid" => tzid)
    end

    def tzid
      @tzid ||= source.dtstart.time_zone.name
    end
  end
end
