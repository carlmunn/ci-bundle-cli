module CiBundle
  module Cli
    class Notifier
      # Currently only email or stdout
      def initialize(opts={})
        @opts = opts
      end

      # Could be failure or success
      def process(body_hash, by: nil)
        case by
        when :email
          _email(body_hash)
        else
          _output(body_hash)
        end
      end

      def notify_exception(exp)
        _body = "exp: #{_escape(exp.to_s)}<br><br>#{exp.backtrace.join("<br>")}"

        _data = {subject: email_subject('Tests raised an exception'), body: _body}
        _opts = {notify: @opts[:email].first}

        CiBundle::Cli::Mailer.new(_data, opts: @opts).deliver!
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

      def _escape(str)
        CGI::escapeHTML(str)
      end

      def email_subject(subject)
        [].tap do |ary|
          ary << "[#{@opts[:namespace]}]" if @opts[:namespace]
          ary << subject
        end.join(" ")
      end
    end
  end
end