require "test_helper"

class RecurrenceExpanderTest < ActiveSupport::TestCase
  test "returns event as-is when no recurrence" do
    event = { titre: "Stage", date_debut: "2026-04-15T19:00:00+02:00", date_fin: "2026-04-15T21:00:00+02:00" }
    result = RecurrenceExpander.expand(event)
    assert_equal 1, result.size
    assert_equal "Stage", result.first[:titre]
  end

  test "returns event as-is when recurrence is nil" do
    event = { titre: "Stage", recurrence: nil }
    result = RecurrenceExpander.expand(event)
    assert_equal 1, result.size
  end

  test "expands weekly friday recurrence" do
    event = {
      titre: "Vagues du soir",
      professor_nom: "Marc Silvestre",
      lieu: "Paris",
      prix_normal: 20.0,
      date_debut: "2026-04-10T19:30:00+02:00",
      date_fin: "2026-04-10T21:30:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:30",
        "time_end" => "21:30",
        "excluded_dates" => [],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      # From April 10 (first friday after April 8) to Aug 28 (last friday before Aug 31)
      assert result.size > 15, "Expected > 15 events, got #{result.size}"
      assert result.size < 25, "Expected < 25 events, got #{result.size}"

      # All should be fridays
      result.each do |e|
        date = Date.parse(e[:date_debut])
        assert_equal 5, date.wday, "Expected friday, got #{date.strftime('%A')} for #{date}"
      end

      # No recurrence field in expanded events
      result.each do |e|
        assert_nil e[:recurrence]
        assert_nil e["recurrence"]
      end

      # First event should be April 10
      assert_equal "2026-04-10", Date.parse(result.first[:date_debut]).to_s

      # Titre preserved
      assert_equal "Vagues du soir", result.first[:titre]
    end
  end

  test "excludes specific dates" do
    event = {
      titre: "Cours",
      date_debut: "2026-04-10T19:00:00+02:00",
      date_fin: "2026-04-10T21:00:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:00",
        "time_end" => "21:00",
        "excluded_dates" => ["2026-04-17", "2026-05-01"],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      dates = result.map { |e| Date.parse(e[:date_debut]).to_s }
      assert_not_includes dates, "2026-04-17"
      assert_not_includes dates, "2026-05-01"
      assert_includes dates, "2026-04-10"
      assert_includes dates, "2026-04-24"
    end
  end

  test "excludes date ranges" do
    event = {
      titre: "Cours",
      date_debut: "2026-04-10T19:00:00+02:00",
      date_fin: "2026-04-10T21:00:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:00",
        "time_end" => "21:00",
        "excluded_dates" => [],
        "excluded_ranges" => [{ "from" => "2026-07-10", "to" => "2026-07-31" }]
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      dates = result.map { |e| Date.parse(e[:date_debut]) }
      july_dates = dates.select { |d| d.month == 7 && d.day >= 10 }
      assert_empty july_dates, "Expected no events during July 10-31 vacation"
    end
  end

  test "handles french day names" do
    event = {
      titre: "Cours",
      date_debut: "2026-04-10T19:00:00+02:00",
      date_fin: "2026-04-10T21:00:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "vendredi",
        "time_start" => "19:00",
        "time_end" => "21:00",
        "excluded_dates" => [],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      assert result.size > 15
      result.each { |e| assert_equal 5, Date.parse(e[:date_debut]).wday }
    end
  end

  test "handles string keys in event data" do
    event = {
      "titre" => "Cours",
      "date_debut" => "2026-04-10T19:00:00+02:00",
      "date_fin" => "2026-04-10T21:00:00+02:00",
      "recurrence" => {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:00",
        "time_end" => "21:00",
        "excluded_dates" => [],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      assert result.size > 15
    end
  end

  test "end date wraps to next year if past august" do
    event = {
      titre: "Cours",
      date_debut: "2026-09-05T19:00:00+02:00",
      date_fin: "2026-09-05T21:00:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:00",
        "time_end" => "21:00",
        "excluded_dates" => [],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 9, 1) do
      result = RecurrenceExpander.expand(event)
      assert result.size > 40, "Expected > 40 events (Sept to Aug next year), got #{result.size}"
      last_date = Date.parse(result.last[:date_debut])
      assert last_date <= Date.new(2027, 8, 31)
    end
  end

  test "respects start_date and end_date from recurrence" do
    event = {
      titre: "Saison 2025/2026",
      date_debut: "2025-09-05T19:30:00+02:00",
      date_fin: "2025-09-05T21:30:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:30",
        "time_end" => "21:30",
        "start_date" => "2025-09-05",
        "end_date" => "2026-06-27",
        "excluded_dates" => [],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      first_date = Date.parse(result.first[:date_debut])
      last_date = Date.parse(result.last[:date_debut])

      # Starts from today (April 8) not from Sept 5 (past)
      assert first_date >= Date.new(2026, 4, 8), "First date should be >= today"
      # Ends at June 27, not August 31
      assert last_date <= Date.new(2026, 6, 27), "Last date should be <= end_date (June 27), got #{last_date}"
      assert result.size < 13, "Expected < 13 events (Apr 10 to Jun 26), got #{result.size}"
    end
  end

  test "start_date in future delays expansion" do
    event = {
      titre: "Prochaine saison",
      date_debut: "2026-09-04T19:00:00+02:00",
      date_fin: "2026-09-04T21:00:00+02:00",
      recurrence: {
        "type" => "weekly",
        "day_of_week" => "friday",
        "time_start" => "19:00",
        "time_end" => "21:00",
        "start_date" => "2026-09-04",
        "end_date" => "2027-06-25",
        "excluded_dates" => [],
        "excluded_ranges" => []
      }
    }

    travel_to Date.new(2026, 4, 8) do
      result = RecurrenceExpander.expand(event)
      first_date = Date.parse(result.first[:date_debut])
      # Should start from Sep 4, not today
      assert first_date >= Date.new(2026, 9, 4), "First date should be >= start_date (Sep 4), got #{first_date}"
    end
  end
end
