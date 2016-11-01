module CiBundle
  module Cli

    ExampleObj = Struct.new(:desc, :file, :exception, :backtrace)

    class RspecMailRenderor < Mustache

      LIMIT_BT       = 15
      IGNORE_GEM_DIR = true

      self.template_file = File.join(File.dirname(__FILE__), '../../../templates/email-basic.html.mustache')

      attr_accessor :title, :body

      # Root keys: [:to, :from, :subject, :body_hash]
      def initialize(hash_data, opts: {})
        @hsh   = hash_data
        @opts  = opts

        @title = @hsh[:title]
        @body  = @hsh[:body_hash]
      end

      def summary
        rspec_hash["summary"]
      end

      def example_size
        examples.size
      end

      def examples
        rspec_hash["examples"]
      end

      def rspec_hash
        @hsh[:body_hash]
      end

      def failures
        examples.select { |example| example["status"] == "failed" }.map do |hsh|
          _file = "#{hsh["file_path"]}:#{hsh["line_number"]}"
          ExampleObj.new(hsh["full_description"], _file, hsh["exception"], filter_backtrace(hsh["exception"]))
        end
      end

      private
      def filter_backtrace(exp)
        exp["backtrace"].reject do |str|
          str.match(/\/gems\//) || str.match(/\/\.gem\//) if IGNORE_GEM_DIR
        end[0...LIMIT_BT]
      end
    end

    class Mailer
      def initialize(details, opts: {})
        @opts    = opts
        @emails  = @opts[:email]
        @details = details
      end

      def deliver!

        valid_details?(@details)
        valid_email?(@emails)

        _emails  = @emails
        _details = @details
        _body    = render(@details)

        _log("MAIL to: #{@emails.inspect}")

        mail = Mail.new do
          from         _emails.first
          to           _details[:to] || _emails
          subject      _details[:subject]
          content_type 'text/html; charset=UTF-8'
          body         _body
        end

        mail.deliver!

        _log("MAIL deliver!: #{mail.inspect}")
      end

      private
      def render(hash_or_str)
        if hash_or_str[:body_hash].is_a?(Hash)
          renderor = RspecMailRenderor.new(hash_or_str, opts: @opts)
          renderor.render
        else
          hash_or_str[:body] || '--'
        end
      end

      def valid_details?(details)
        if details[:subject].nil? && details[:body].nil?
          raise 'Email Body and Subject blank!'
        end
      end

      def valid_email?(email)
        if @emails.nil?
          raise 'No emails supplied'
        end
      end

      def _log(msg)
        CiBundle::Cli.log(msg)
      end
    end
  end
end