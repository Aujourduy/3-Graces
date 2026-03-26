require "application_system_test_case"

class AdminTest < ApplicationSystemTestCase
  setup do
    @admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
    @admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme")
  end

  test "admin requires HTTP Basic Auth" do
    visit admin_root_path

    # Should be denied without auth
    assert_text /Access denied|Unauthorized/i, wait: 2
  end

  test "admin login with HTTP Basic Auth works" do
    # Capybara Playwright supports HTTP Basic Auth via URL
    # Format: http://username:password@host:port/path
    # Use Capybara's current session URL to get the correct port
    port = Capybara.current_session.server.port
    authenticated_url = "http://#{@admin_username}:#{@admin_password}@127.0.0.1:#{port}/admin"

    visit authenticated_url

    # Should see admin dashboard
    assert_selector "h1", text: /Admin/i
    assert_text "URLs"
    assert_text "Événements"
  end
end
