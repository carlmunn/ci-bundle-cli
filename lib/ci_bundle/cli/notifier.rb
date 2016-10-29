module CiBundle
  module Cli
    class Notifier

      # Currently only email or stdout
      def initialize(opts={})
        @opts   = opts

      end

      def process(data, by: nil)
        case by
        when :email
          _email(data)
        else
          _output(data)
        end
      end

      private
      def _output(msg)
        puts ['[Notifier:Start]', msg, '[Notifier:End]'].join("\n")
      end

      # --email option will contain who to email to
      def _email(details)
        mailer = CiBundle::Cli::Mailer.new(details, opts: @opts)
        mailer.deliver!
      end
    end
  end
end