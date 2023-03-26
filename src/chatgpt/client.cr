require "http/client"
require "./config"

module ChatGPT
  class ApiKeyError < Exception; end

  class Client
    API_ENDPOINT = "https://api.openai.com/v1/chat/completions"

    @http_headers : HTTP::Headers
    getter config : Config

    def initialize(@config : Config)
      @http_headers = build_http_headers
    end

    def build_http_headers
      HTTP::Headers{
        "Authorization" => "Bearer #{fetch_api_key}",
        "Content-Type"  => "application/json",
      }
    end

    def fetch_api_key
      if ENV.has_key?("OPENAI_API_KEY")
        ENV["OPENAI_API_KEY"]
      else
        STDERR.puts "Error: OPENAI_API_KEY is not set. ".colorize(:yellow).mode(:bold)
        STDERR.puts "Please get your API key and set it as an environment variable.".colorize(:yellow)
        ""
      end
    end

    def send_chat_request(request_data)
      log_request_data(request_data) if debug_mode?

      spinner = create_spinner
      spinner.start

      chat_response = post_request(request_data)
      spinner.stop

      log_response_data(chat_response) if debug_mode?
      chat_response
    end

    def post_request(request_data)
      HTTP::Client.post(API_ENDPOINT, body: request_data.to_json, headers: @http_headers)
    rescue error
      STDERR.puts "Error: #{error} #{error.message}".colorize(:red)
      exit 1
    end

    private def create_spinner
      spinner_text = "ChatGPT".colorize.fore(@config.color_chatgpt_fore).back(@config.color_chatgpt_back)
      Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text, output: STDERR)
    end

    private def debug_mode?
      DEBUG_FLAG[0]
    end

    private def log_request_data(request_data)
      STDERR.puts
      STDERR.puts "Sending request to #{API_ENDPOINT}".colorize(:cyan).mode(:bold)
      STDERR.puts request_data.pretty_inspect.colorize(:cyan)
      STDERR.puts
    end

    private def log_response_data(chat_response)
      STDERR.puts "Received response from #{API_ENDPOINT}".colorize(:cyan).mode(:bold)
      STDERR.puts "Response status: #{chat_response.status}".colorize(:cyan)
      STDERR.puts "Response body: #{JSON.parse(chat_response.body).pretty_inspect}".colorize(:cyan)
      STDERR.puts
    end
  end
end
