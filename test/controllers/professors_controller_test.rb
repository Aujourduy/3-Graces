require "test_helper"

class ProfessorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @professor = Professor.create!(
      nom: "Test Professor",
      site_web: "https://example.com",
      bio: "A test professor bio",
      consultations_count: 0,
      clics_sortants_count: 0
    )

    @event = Event.create!(
      titre: "Future Event",
      date_debut: 2.days.from_now,
      date_fin: 2.days.from_now + 2.hours,
      lieu: "Paris",
      professor: @professor,
      type_event: :atelier
    )
  end

  test "should get show" do
    get professeur_url(@professor)
    assert_response :success
  end

  test "should increment consultations_count on show" do
    initial_count = @professor.consultations_count

    get professeur_url(@professor)

    @professor.reload
    assert_equal initial_count + 1, @professor.consultations_count
  end

  test "should load upcoming events on show" do
    past_event = Event.create!(
      titre: "Past Event",
      date_debut: 2.days.ago,
      date_fin: 2.days.ago + 2.hours,
      lieu: "Paris",
      professor: @professor,
      type_event: :atelier
    )

    get professeur_url(@professor)
    assert_response :success

    assert_select "h3", text: @event.titre
    assert_select "h3", text: past_event.titre, count: 0
  end

  test "should get stats" do
    get stats_professeur_url(@professor)
    assert_response :success
  end

  test "stats page should not increment consultations_count" do
    initial_count = @professor.consultations_count

    get stats_professeur_url(@professor)

    @professor.reload
    assert_equal initial_count, @professor.consultations_count
  end

  test "should redirect to professor website" do
    initial_count = @professor.clics_sortants_count

    get redirect_to_site_professeur_url(@professor)

    assert_redirected_to @professor.site_web
    assert_equal 303, response.status # :see_other

    @professor.reload
    assert_equal initial_count + 1, @professor.clics_sortants_count
  end

  test "should redirect if professor not found" do
    get professeur_url(id: 99999)
    assert_redirected_to evenements_path
    assert_match /Professeur introuvable/, flash[:alert]
  end
end
