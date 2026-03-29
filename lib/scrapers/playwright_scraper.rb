require "playwright"

module Scrapers
  class PlaywrightScraper
    USER_AGENT = "stopand.dance bot - contact@stopand.dance"

    def self.fetch(url)
      # Launch Playwright browser (Chromium headless)
      Playwright.create(playwright_cli_executable_path: "./node_modules/.bin/playwright") do |playwright|
        playwright.chromium.launch(headless: true) do |browser|
          context = browser.new_context(
            userAgent: USER_AGENT,
            viewport: { width: 1920, height: 1080 }
          )

          page = context.new_page

          begin
            # Navigate to URL with domcontentloaded (faster for Wix/SPAs with analytics)
            # networkidle doesn't work with Wix: analytics scripts never become idle
            page.goto(url, waitUntil: "domcontentloaded", timeout: 120_000)

            # Wait for JavaScript to fully execute and render content
            page.wait_for_timeout(5000) # 5s for JS rendering + lazy-loading

            # Scroll to bottom to trigger lazy-loading
            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            page.wait_for_timeout(2000) # 2s after scroll

            # Get final HTML after JS execution
            html = page.content

            {
              html: html,
              status: 200,
              content_type: "text/html",
              method: "playwright"
            }
          rescue Playwright::TimeoutError => e
            {
              error: "Playwright timeout: #{e.message}",
              status: nil
            }
          rescue StandardError => e
            {
              error: "Playwright error: #{e.message}",
              status: nil
            }
          ensure
            page.close
            context.close
          end
        end
      end
    rescue StandardError => e
      {
        error: "Playwright launch failed: #{e.message}",
        status: nil
      }
    end
  end
end
