class ScrapingVerify
  SCREENSHOT_DIR = Rails.root.join("tmp", "scraping_verify_screenshots")
  REPORT_PATH = Rails.root.join("tmp", "scraping_verify_report.md")
  CLAUDE_CLI_PATH = "/home/dang/.local/bin/claude"
  TIMEOUT_SECONDS = 90

  def self.run_all
    urls = ScrapedUrl.where(statut_scraping: "actif")
                     .where.not("url LIKE ?", "%example.com%")
                     .where.not("url LIKE ?", "%localhost%")

    FileUtils.mkdir_p(SCREENSHOT_DIR)
    results = urls.map { |su| verify_one(su) }
    generate_report(results)
    results
  end

  def self.verify_one(scraped_url)
    result = {
      url_id: scraped_url.id, url: scraped_url.url, nom: scraped_url.nom,
      status: nil, issues: [], summary: nil, error: nil, duration_ms: 0
    }
    start = Time.current

    # Step 1: Screenshot with Playwright
    screenshot_path = SCREENSHOT_DIR.join("url_#{scraped_url.id}.png").to_s
    screenshot_ok = take_screenshot(scraped_url.url, screenshot_path)

    unless screenshot_ok
      result[:error] = "Screenshot failed"
      result[:status] = "error"
      result[:duration_ms] = ((Time.current - start) * 1000).round
      return result
    end

    # Step 2: Get events from DB for this URL
    events = Event.where(scraped_url: scraped_url).futurs.order(:date_debut_date).map do |e|
      {
        titre: e.titre,
        date: e.date_debut_date.to_s,
        heure: e.display_heure_debut,
        lieu: e.lieu,
        prix_normal: e.prix_normal,
        type: e.type_event
      }
    end

    if events.empty?
      result[:status] = "skip"
      result[:summary] = "Aucun event futur en DB pour cette URL"
      result[:duration_ms] = ((Time.current - start) * 1000).round
      return result
    end

    # Step 3: Ask Claude to verify
    claude_result = ask_claude(screenshot_path, events.to_json)

    if claude_result[:error]
      result[:error] = claude_result[:error]
      result[:status] = "error"
    else
      result[:status] = claude_result[:status]
      result[:issues] = claude_result[:issues] || []
      result[:summary] = claude_result[:summary]
    end

    result[:duration_ms] = ((Time.current - start) * 1000).round
    result
  rescue => e
    result[:error] = "Exception: #{e.class}: #{e.message}"
    result[:status] = "error"
    result[:duration_ms] = ((Time.current - start) * 1000).round
    result
  end

  private

  def self.take_screenshot(url, path)
    script = <<~JS
      const { chromium } = require('playwright');
      (async () => {
        const browser = await chromium.launch();
        const page = await (await browser.newContext({ viewport: { width: 1280, height: 800 } })).newPage();
        await page.goto('#{url}', { waitUntil: 'domcontentloaded' });
        await page.waitForTimeout(5000);
        await page.screenshot({ path: '#{path}', fullPage: true });
        await browser.close();
      })();
    JS
    script_path = Rails.root.join("tmp", "screenshot_verify.js").to_s
    File.write(script_path, script)
    system("node", script_path, chdir: Rails.root.to_s, exception: false)
    File.exist?(path)
  rescue => e
    SCRAPING_LOGGER.error({ event: "screenshot_failed", url: url, error: e.message }.to_json)
    false
  end

  def self.ask_claude(screenshot_path, events_json)
    prompt = <<~PROMPT
      Tu es un vérificateur QA. Regarde le screenshot du site web dans le fichier #{screenshot_path}

      Voici les événements scrapés et stockés en base de données :
      #{events_json}

      Compare visuellement le screenshot avec les données JSON.
      Vérifie : titres, dates, horaires, lieux, prix.

      Réponds UNIQUEMENT en JSON valide, sans texte avant ou après :
      {
        "status": "match" ou "mismatch" ou "partial",
        "issues": ["description du problème 1", "..."],
        "summary": "résumé en 1 phrase"
      }
    PROMPT

    output, status = Open3.capture2e(
      CLAUDE_CLI_PATH, "-p", "--dangerously-skip-permissions",
      stdin_data: prompt
    )

    unless status.success?
      return { error: "Claude CLI failed: #{output.to_s.first(200)}" }
    end

    json_match = output.match(/\{.*\}/m)
    return { error: "No JSON in Claude response" } unless json_match

    parsed = JSON.parse(json_match[0], symbolize_names: true)
    { status: parsed[:status], issues: parsed[:issues], summary: parsed[:summary] }
  rescue JSON::ParserError => e
    { error: "JSON parse error: #{e.message}" }
  rescue => e
    { error: "Claude error: #{e.message}" }
  end

  def self.generate_report(results)
    match_count = results.count { |r| r[:status] == "match" }
    partial_count = results.count { |r| r[:status] == "partial" }
    mismatch_count = results.count { |r| r[:status] == "mismatch" }
    error_count = results.count { |r| r[:status] == "error" }
    skip_count = results.count { |r| r[:status] == "skip" }
    total_duration = results.sum { |r| r[:duration_ms] || 0 }

    report = <<~MD
      # Scraping Verify Report

      **Date :** #{Date.current}
      **Durée totale :** #{(total_duration / 1000.0).round(1)}s

      ## Résumé

      | Status | Count |
      |--------|-------|
      | ✅ Match | #{match_count} |
      | ⚠️ Partial | #{partial_count} |
      | ❌ Mismatch | #{mismatch_count} |
      | 💀 Error | #{error_count} |
      | ⏭️ Skip | #{skip_count} |
      | **Total** | **#{results.size}** |

      ## Détails

    MD

    results.each do |r|
      icon = case r[:status]
             when "match" then "✅"
             when "partial" then "⚠️"
             when "mismatch" then "❌"
             when "skip" then "⏭️"
             else "💀"
             end

      label = r[:nom].presence || r[:url].to_s.truncate(60)
      report += "### #{icon} ##{r[:url_id]} #{label} (#{r[:duration_ms]}ms)\n\n"

      if r[:error]
        report += "**Erreur :** #{r[:error]}\n\n"
      elsif r[:status] == "skip"
        report += "#{r[:summary]}\n\n"
      else
        report += "**Status :** #{r[:status]}\n\n"
        report += "**Résumé :** #{r[:summary]}\n\n" if r[:summary]
        if r[:issues]&.any?
          report += "**Issues :**\n"
          r[:issues].each { |i| report += "- #{i}\n" }
          report += "\n"
        end
      end
    end

    File.write(REPORT_PATH, report)
    puts report
    REPORT_PATH
  end
end
