require "test_helper"

class NewslettersControllerTest < ActionDispatch::IntegrationTest
  test "should create newsletter subscription with valid email" do
    assert_difference("Newsletter.count", 1) do
      post newsletters_url, params: { newsletter: { email: "test@example.com" } }
    end

    assert_redirected_to evenements_path
    assert_equal "Merci ! Vous êtes inscrit(e) à notre newsletter.", flash[:notice]

    newsletter = Newsletter.last
    assert_equal "test@example.com", newsletter.email
    assert newsletter.actif
    assert_not_nil newsletter.consenti_at
  end

  test "should not create duplicate newsletter subscription" do
    Newsletter.create!(email: "existing@example.com")

    assert_no_difference("Newsletter.count") do
      post newsletters_url, params: { newsletter: { email: "existing@example.com" } }
    end

    assert_redirected_to evenements_path
    assert_equal "Cette adresse email est déjà inscrite à notre newsletter.", flash[:notice]
  end

  test "should not create newsletter with invalid email" do
    assert_no_difference("Newsletter.count") do
      post newsletters_url, params: { newsletter: { email: "invalid-email" } }
    end

    assert_redirected_to evenements_path
    assert_match /Erreur/, flash[:alert]
  end

  test "should not create newsletter without email" do
    assert_no_difference("Newsletter.count") do
      post newsletters_url, params: { newsletter: { email: "" } }
    end

    assert_redirected_to evenements_path
    assert_match /Erreur/, flash[:alert]
  end

  test "duplicate email should use notice not alert" do
    Newsletter.create!(email: "test@example.com")

    post newsletters_url, params: { newsletter: { email: "test@example.com" } }

    assert_nil flash[:alert]
    assert_not_nil flash[:notice]
  end
end
