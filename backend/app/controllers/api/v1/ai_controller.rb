class Api::V1::AiController < ApplicationController
  before_action :authenticate_user!

  def summarize
    content = params[:content].to_s.strip
    style = params[:style].to_s.presence || "bullet"

    if content.blank?
      return render json: { error: "Conteudo vazio para resumir." }, status: :unprocessable_entity
    end

    summary_style =
      if style == "paragraph"
        "Entregue em 1 paragrafo curto com linguagem clara em portugues brasileiro."
      else
        "Entregue em bullets curtos (4 a 7 itens) em portugues brasileiro."
      end

    result = openai_client.chat(
      system_prompt: "Voce e um assistente que resume textos mantendo fidelidade ao conteudo.",
      user_prompt: <<~PROMPT,
        Resuma o texto abaixo.
        #{summary_style}
        Nao invente fatos.

        Texto:
        #{content}
      PROMPT
      max_tokens: 450
    )

    render json: { result: result }
  rescue OpenaiClient::ConfigurationError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue OpenaiClient::RequestError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def translate_terms
    content = params[:content].to_s.strip
    limit = params[:limit].to_i
    limit = 12 if limit <= 0
    limit = 25 if limit > 25

    if content.blank?
      return render json: { error: "Conteudo vazio para traduzir termos." }, status: :unprocessable_entity
    end

    result = openai_client.chat(
      system_prompt: "Voce e um assistente de traducao tecnica.",
      user_prompt: <<~PROMPT,
        Extraia ate #{limit} termos importantes do texto e traduza de portugues para ingles.
        Responda apenas no formato abaixo, uma linha por termo:
        termo_pt | termo_en | contexto_curto
        Nao inclua cabecalho.

        Texto:
        #{content}
      PROMPT
      max_tokens: 700
    )

    render json: { result: result }
  rescue OpenaiClient::ConfigurationError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue OpenaiClient::RequestError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def generate_text
    question = params[:question].to_s.strip
    context = params[:context].to_s.strip

    if question.blank?
      return render json: { error: "Pergunta vazia para gerar texto." }, status: :unprocessable_entity
    end

    result = openai_client.chat(
      system_prompt: "Voce e um assistente de escrita. Responda em portugues brasileiro, com clareza e objetividade.",
      user_prompt: <<~PROMPT,
        Gere um texto com base na pergunta do usuario.
        Se houver contexto, use apenas como apoio.
        Evite inventar fatos e sinalize incerteza quando necessario.

        Pergunta:
        #{question}

        Contexto opcional:
        #{context.presence || "(sem contexto adicional)"}
      PROMPT
      max_tokens: 800
    )

    render json: { result: result }
  rescue OpenaiClient::ConfigurationError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue OpenaiClient::RequestError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  private

  def openai_client
    @openai_client ||= OpenaiClient.new
  end
end