require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @professor = Professor.create!(
      nom: "Test Professor",
      site_web: "https://example.com"
    )

    @event = Event.create!(
      titre: "Test Event",
      date_debut: 2.days.from_now,
      date_fin: 2.days.from_now + 2.hours,
      lieu: "Paris",
      adresse_complete: "123 Test St, Paris",
      professor: @professor,
      type_event: :atelier,
      gratuit: false,
      prix_normal: 25.0
    )
  end

  test "should get index" do
    get evenements_url
    assert_response :success
  end

  test "should get show" do
    get evenement_url(@event.slug)
    assert_response :success
  end

  test "index should only show future events" do
    past_event = Event.create!(
      titre: "Past Event",
      date_debut: 2.days.ago,
      date_fin: 2.days.ago + 2.hours,
      lieu: "Paris",
      professor: @professor,
      type_event: :atelier
    )

    get evenements_url
    assert_response :success
    assert_select "h3", text: @event.titre
    assert_select "h3", text: past_event.titre, count: 0
  end

  test "show should increment professor consultations count" do
    initial_count = @professor.consultations_count || 0

    get evenement_url(@event.slug)

    @professor.reload
    assert_equal initial_count + 1, @professor.consultations_count
  end

  test "show should redirect if event not found" do
    get evenement_url("invalid-slug")
    assert_redirected_to evenements_path
  end
end
