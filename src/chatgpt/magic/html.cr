require "./base"

module ChatGPT
  class Magic
    class Html < Base
      def initialize(sender)
        @sender = sender
        @name = "html"
        @description = "Show data in the browser"
        @patterns = [/\Ahtml\z/, /\Ahtml\s+(.+)/]
      end

      def run
        timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
        file_name = "chatgpt-#{timestamp}.html"
        run(file_name)
      end

      def run(file_name)
        html = Generator::Html.new(data).to_s
        File.write(file_name, html)
        puts "Saved to #{file_name}"._colorize(:warning)
        open_browser(file_name)
        true
      end
    end
  end
end
