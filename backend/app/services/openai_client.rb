require "net/http"
require "json"

class OpenaiClient
  class ConfigurationError < StandardError; end
  class RequestError < StandardError; end

  def initialize(
    api_key: ENV["OPENAI_API_KEY"],
    model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
    base_url: ENV.fetch("OPENAI_API_BASE", "https://api.openai.com/v1")
  )
    @api_key = api_key
    @model = model
    @base_url = base_url
  end

  def chat(system_prompt:, user_prompt:, temperature: 0.2, max_tokens: 500)
    raise ConfigurationError, "OPENAI_API_KEY ausente." if @api_key.blank?

    uri = URI("#{@base_url}/chat/completions")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"

    request.body = {
      model: @model,
      temperature: temperature,
      max_tokens: max_tokens,
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ]
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.read_timeout = 60
      http.open_timeout = 15
      http.request(request)
    end

    parsed = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      message = parsed.dig("error", "message") || "Falha na API OpenAI"
      raise RequestError, message
    end

    parsed.dig("choices", 0, "message", "content").to_s.strip
  rescue JSON::ParserError
    raise RequestError, "Resposta invalida da OpenAI"
  end
end