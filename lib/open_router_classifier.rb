class OpenRouterClassifier
  PROMPT = <<~PROMPT
    Tu es un classifieur. Réponds UNIQUEMENT par "oui" ou "non" (un seul mot, en minuscules).

    Question : Le contenu markdown suivant contient-il la description d'au moins un atelier, stage, ou cours de danse avec une date (jour, mois, ou date complète) ?

    Contenu :
    %{markdown}
  PROMPT

  def self.classify(markdown:, model:)
    return { verdict: nil, error: "API key missing" } if OPEN_ROUTER_CONFIG[:api_key].blank?
    return { verdict: nil, error: "Empty markdown" } if markdown.blank?

    truncated = markdown.first(10_000)
    prompt = format(PROMPT, markdown: truncated)

    response = HTTParty.post(
      "#{OPEN_ROUTER_CONFIG[:base_url]}/chat/completions",
      headers: {
        "Authorization" => "Bearer #{OPEN_ROUTER_CONFIG[:api_key]}",
        "Content-Type" => "application/json",
        "HTTP-Referer" => "https://stopand.dance",
        "X-Title" => "Stop & Dance"
      },
      body: {
        model: model,
        messages: [{ role: "user", content: prompt }],
        temperature: 0,
        max_tokens: 10
      }.to_json,
      timeout: OPEN_ROUTER_CONFIG[:timeout]
    )

    if response.success?
      raw = response.dig("choices", 0, "message", "content").to_s.strip.downcase
      verdict = if raw.start_with?("oui")
        true
      elsif raw.start_with?("non")
        false
      end
      sleep OPEN_ROUTER_CONFIG[:rate_limit_sleep]
      { verdict: verdict, error: verdict.nil? ? "Unparseable response: #{raw}" : nil }
    else
      { verdict: nil, error: "HTTP #{response.code}: #{response.body.to_s.first(200)}" }
    end
  rescue => e
    { verdict: nil, error: e.message }
  end
end
