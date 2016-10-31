module CiBundle
  module Cli
    class Notifier

      # Currently only email or stdout
      def initialize(opts={})
        @opts = opts
      end

      def process(body_hash, by: nil)
        case by
        when :email
          _email(body_hash)
        else
          _output(body_hash)
        end
      end

      private
      def _output(body_hash)
        puts ['[Notifier:Start]', body_hash.inspect, '[Notifier:End]'].join("\n")
      end

      # --email option will contain who to email to
      def _email(body_hash)
        mailer = CiBundle::Cli::Mailer.new(body_hash, opts: @opts)
        mailer.deliver!
      end
    end
  end
end