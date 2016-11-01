module CiBundle
  module Cli
    class Parser
      def initialize(opts={}); end

      def process(str, input_type: nil)
        case input_type
        when :json
          JSON.load(str)
        else
          str
        end
      end
    end
  end
end
