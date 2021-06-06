# frozen_string_literal: true

require_relative "./livecal/calendar_source"
require_relative "./livecal/parser"

module Livecal
  def self.from_url(url, from:, to:)
    from_sources CalendarSource.from_url(url), from: from, to: to
  end

  def self.from_file(path, from:, to:)
    from_sources CalendarSource.from_file(path), from: from, to: to
  end

  def self.from_string(contents, from:, to:)
    from_sources CalendarSource.from_string(contents), from: from, to: to
  end

  def self.from_sources(sources, from:, to:)
    sources.collect { |source| Parser.call(source, from: from, to: to) }
  end
end
