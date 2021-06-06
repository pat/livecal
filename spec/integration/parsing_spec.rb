# frozen_string_literal: true

RSpec.describe "Parsing ical files" do
  let(:from) { Time.new 2021, 6, 6, 0, 0, 0, tz }
  let(:to) { Time.new 2021, 6, 7, 0, 0, 0, tz }
  let(:tz) { "+10:00" }

  context "handles a single event" do
    let(:source) do
      <<~ICAL
        BEGIN:VCALENDAR
        PRODID:-//Google Inc//Google Calendar 70.9054//EN
        VERSION:2.0
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        X-WR-CALNAME:livecal
        X-WR-TIMEZONE:Australia/Melbourne
        BEGIN:VEVENT
        DTSTART:20210606T020000Z
        DTEND:20210606T030000Z
        DTSTAMP:20210606T013959Z
        UID:6vc8dul781vckb41vh5avkchi3@google.com
        CREATED:20210606T013948Z
        DESCRIPTION:
        LAST-MODIFIED:20210606T013948Z
        LOCATION:
        SEQUENCE:0
        STATUS:CONFIRMED
        SUMMARY:Appointment
        TRANSP:OPAQUE
        END:VEVENT
        END:VCALENDAR
      ICAL
    end

    it "returns the event if in the requested window" do
      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events.length).to eq(1)

      event = calendars.first.events.first

      expect(event.summary).to eq("Appointment")
    end

    it "returns no events if the event is outside the requested window" do
      from = Time.new 2021, 6, 7, 0, 0, 0, tz
      to = Time.new 2021, 6, 7, 23, 0, 0, tz

      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events).to be_empty
    end
  end

  context "with recurring events" do
    let(:source) do
      <<~ICAL
        BEGIN:VCALENDAR
        PRODID:-//Google Inc//Google Calendar 70.9054//EN
        VERSION:2.0
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        X-WR-CALNAME:livecal
        X-WR-TIMEZONE:Australia/Melbourne
        BEGIN:VTIMEZONE
        TZID:Australia/Melbourne
        X-LIC-LOCATION:Australia/Melbourne
        BEGIN:STANDARD
        TZOFFSETFROM:+1100
        TZOFFSETTO:+1000
        TZNAME:AEST
        DTSTART:19700405T030000
        RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU
        END:STANDARD
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+1000
        TZOFFSETTO:+1100
        TZNAME:AEDT
        DTSTART:19701004T020000
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=1SU
        END:DAYLIGHT
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=Australia/Melbourne:20210606T120000
        DTEND;TZID=Australia/Melbourne:20210606T130000
        RRULE:FREQ=WEEKLY;BYDAY=SU
        DTSTAMP:20210606T015535Z
        UID:6vc8dul781vckb41vh5avkchi3@google.com
        CREATED:20210606T013948Z
        DESCRIPTION:
        LAST-MODIFIED:20210606T015524Z
        LOCATION:
        SEQUENCE:1
        STATUS:CONFIRMED
        SUMMARY:Appointment
        TRANSP:OPAQUE
        END:VEVENT
        END:VCALENDAR
      ICAL
    end

    it "returns the events in the requested window" do
      from = Time.new 2021, 6, 6, 0, 0, 0, tz
      to = Time.new 2021, 6, 14, 0, 0, 0, tz
      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events.length).to eq(2)

      first, second = calendars.first.events.to_a

      expect(first.summary).to eq("Appointment")
      expect(first.starts_at).to eq(Time.new(2021, 6, 6, 12, 0, 0, tz))
      expect(first.ends_at).to eq(Time.new(2021, 6, 6, 13, 0, 0, tz))

      expect(second.summary).to eq("Appointment")
      expect(second.starts_at).to eq(Time.new(2021, 6, 13, 12, 0, 0, tz))
      expect(second.ends_at).to eq(Time.new(2021, 6, 13, 13, 0, 0, tz))
    end

    it "includes events when the initial instance is outside the window" do
      from = Time.new 2021, 6, 13, 0, 0, 0, tz
      to = Time.new 2021, 6, 14, 0, 0, 0, tz
      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events.length).to eq(1)

      event = calendars.first.events.first

      expect(event.summary).to eq("Appointment")
      expect(event.starts_at).to eq(Time.new(2021, 6, 13, 12, 0, 0, tz))
      expect(event.ends_at).to eq(Time.new(2021, 6, 13, 13, 0, 0, tz))
    end
  end

  context "recurring events with exclusions" do
    let(:source) do
      <<~ICAL
        BEGIN:VCALENDAR
        PRODID:-//Google Inc//Google Calendar 70.9054//EN
        VERSION:2.0
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        X-WR-CALNAME:livecal
        X-WR-TIMEZONE:Australia/Melbourne
        BEGIN:VTIMEZONE
        TZID:Australia/Melbourne
        X-LIC-LOCATION:Australia/Melbourne
        BEGIN:STANDARD
        TZOFFSETFROM:+1100
        TZOFFSETTO:+1000
        TZNAME:AEST
        DTSTART:19700405T030000
        RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU
        END:STANDARD
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+1000
        TZOFFSETTO:+1100
        TZNAME:AEDT
        DTSTART:19701004T020000
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=1SU
        END:DAYLIGHT
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=Australia/Melbourne:20210606T120000
        DTEND;TZID=Australia/Melbourne:20210606T130000
        RRULE:FREQ=WEEKLY;BYDAY=SU
        EXDATE;TZID=Australia/Melbourne:20210613T120000
        DTSTAMP:20210606T031826Z
        UID:6vc8dul781vckb41vh5avkchi3@google.com
        CREATED:20210606T013948Z
        DESCRIPTION:
        LAST-MODIFIED:20210606T015524Z
        LOCATION:
        SEQUENCE:1
        STATUS:CONFIRMED
        SUMMARY:Appointment
        TRANSP:OPAQUE
        END:VEVENT
        END:VCALENDAR
      ICAL
    end

    it "returns the events in the requested window" do
      from = Time.new 2021, 6, 6, 0, 0, 0, tz
      to = Time.new 2021, 6, 21, 0, 0, 0, tz
      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events.length).to eq(2)

      first, second = calendars.first.events.to_a

      expect(first.summary).to eq("Appointment")
      expect(first.starts_at).to eq(Time.new(2021, 6, 6, 12, 0, 0, tz))
      expect(first.ends_at).to eq(Time.new(2021, 6, 6, 13, 0, 0, tz))

      expect(second.summary).to eq("Appointment")
      expect(second.starts_at).to eq(Time.new(2021, 6, 20, 12, 0, 0, tz))
      expect(second.ends_at).to eq(Time.new(2021, 6, 20, 13, 0, 0, tz))
    end
  end

  context "recurring events with changes" do
    let(:source) do
      <<~ICAL
        BEGIN:VCALENDAR
        PRODID:-//Google Inc//Google Calendar 70.9054//EN
        VERSION:2.0
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        X-WR-CALNAME:livecal
        X-WR-TIMEZONE:Australia/Melbourne
        BEGIN:VTIMEZONE
        TZID:Australia/Melbourne
        X-LIC-LOCATION:Australia/Melbourne
        BEGIN:STANDARD
        TZOFFSETFROM:+1100
        TZOFFSETTO:+1000
        TZNAME:AEST
        DTSTART:19700405T030000
        RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU
        END:STANDARD
        BEGIN:DAYLIGHT
        TZOFFSETFROM:+1000
        TZOFFSETTO:+1100
        TZNAME:AEDT
        DTSTART:19701004T020000
        RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=1SU
        END:DAYLIGHT
        END:VTIMEZONE
        BEGIN:VEVENT
        DTSTART;TZID=Australia/Melbourne:20210606T120000
        DTEND;TZID=Australia/Melbourne:20210606T130000
        RRULE:FREQ=WEEKLY;BYDAY=SU
        DTSTAMP:20210606T032058Z
        UID:60oght30b0avdekvlsg2bkfi7p@google.com
        CREATED:20210606T032036Z
        DESCRIPTION:
        LAST-MODIFIED:20210606T032036Z
        LOCATION:
        SEQUENCE:0
        STATUS:CONFIRMED
        SUMMARY:Appointment
        TRANSP:OPAQUE
        END:VEVENT
        BEGIN:VEVENT
        DTSTART;TZID=Australia/Melbourne:20210614T130000
        DTEND;TZID=Australia/Melbourne:20210614T140000
        DTSTAMP:20210606T032058Z
        UID:60oght30b0avdekvlsg2bkfi7p@google.com
        RECURRENCE-ID;TZID=Australia/Melbourne:20210613T120000
        CREATED:20210606T032036Z
        DESCRIPTION:
        LAST-MODIFIED:20210606T032050Z
        LOCATION:
        SEQUENCE:1
        STATUS:CONFIRMED
        SUMMARY:Appointment
        TRANSP:OPAQUE
        END:VEVENT
        END:VCALENDAR
      ICAL
    end

    it "returns the events in the requested window" do
      from = Time.new 2021, 6, 6, 0, 0, 0, tz
      to = Time.new 2021, 6, 21, 0, 0, 0, tz
      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events.length).to eq(3)

      first, second, third = calendars.first.events.to_a

      expect(first.summary).to eq("Appointment")
      expect(first.starts_at).to eq(Time.new(2021, 6, 6, 12, 0, 0, tz))
      expect(first.ends_at).to eq(Time.new(2021, 6, 6, 13, 0, 0, tz))

      expect(second.summary).to eq("Appointment")
      expect(second.starts_at).to eq(Time.new(2021, 6, 14, 13, 0, 0, tz))
      expect(second.ends_at).to eq(Time.new(2021, 6, 14, 14, 0, 0, tz))

      expect(third.summary).to eq("Appointment")
      expect(third.starts_at).to eq(Time.new(2021, 6, 20, 12, 0, 0, tz))
      expect(third.ends_at).to eq(Time.new(2021, 6, 20, 13, 0, 0, tz))
    end

    it "factors in changes outside the requested window" do
      from = Time.new 2021, 6, 6, 0, 0, 0, tz
      to = Time.new 2021, 6, 13, 0, 0, 0, tz
      calendars = Livecal.from_string source, from: from, to: to

      expect(calendars.length).to eq(1)
      expect(calendars.first.events.length).to eq(1)

      event = calendars.first.events.first

      expect(event.summary).to eq("Appointment")
      expect(event.starts_at).to eq(Time.new(2021, 6, 6, 12, 0, 0, tz))
      expect(event.ends_at).to eq(Time.new(2021, 6, 6, 13, 0, 0, tz))
    end
  end
end
