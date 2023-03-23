require "../postdata"
require "./version"

module ChatGPT
  module CLI
    class Parser < OptionParser
      def initialize(data : PostData)
        super()
        self.banner = "Usage: #{PROGRAM_NAME} [options]"
        on "-i NAME", "--identifier NAME", "Custom system message from configuration file" do |v|
          begin
            config_data = JSON.parse(File.read("system_messages.json"))
            message = config_data[v]

            data.messages << {"role" => message["role"].to_s, "content" => message["content"].to_s} if message
          rescue ex
            STDERR.puts "Error: Unable to read configuration file: #{ex.message}".colorize(:red).mode(:bold)
            abort
          end
        end
        on "-m MODEL", "--model MODEL", "Model name (default: gpt-3.5-turbo)" do |v|
          data.model = v.to_s
        end
        on "-s STR", "--system STR", "System message" do |v|
          data.messages << {"role" => "system", "content" => v.to_s}
        end
        on "-n INT", "How many edits to generate for the input and instruction." do |v|
          data.n = v.to_i? || (STDERR.puts "Error: Invalid number of edits"; exit 1)
        end
        on "-t Float", "--temperature Float", "Sampling temperature between 0 and 2 affects randomness of output." do |v|
          data.temperature = v.to_f? || (STDERR.puts "Error: Invalid temperature"; exit 1)
        end
        on "-p Float", "--top_p Float", "Nucleus sampling considers top_p probability mass for token selection." do |v|
          data.top_p = v.to_f? || (STDERR.puts "Error: Invalid top_p"; exit 1)
        end
        on "-d", "--debug", "Debug mode" do
          DEBUG_FLAG[0] = true
        end
        on "-v", "--version", "Show version" do
          puts ChatGPT::CLI::VERSION
          exit
        end
        on("-h", "--help", "Show help") { puts self; exit }
      end
    end
  end
end