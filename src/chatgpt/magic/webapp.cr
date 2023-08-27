require "./base"

module ChatGPT
  class Magic
    class Webapp < Base
      def initialize(sender)
        @sender = sender
        @name = "webapp"
        @description = "Open ChatGPT webapp"
        @patterns = [/\Awebapp\z/]
      end

      def run
        # FIXME: do not write url directly
        open_browser("https://chat.openai.com/")
        true
      end
    end
  end
end