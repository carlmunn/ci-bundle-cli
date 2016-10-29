require 'mail'
require 'mustache'

module CiBundle
  module Cli

    class Renderor < Mustache

      self.template_file = File.join(File.dirname(__FILE__), '../../../templates/email-basic.html.mustache')

      attr_accessor :title, :body

      def initialize(data)
        @title = data[:title]
        @body  = data[:body]
      end
    end

    class Mailer
      def initialize(details, opts: {})
        @opts =  opts
        @notify  = @opts[:notify]
        @emails  = @opts[:emails] || @notify
        @details = details
      end

      def deliver!

        valid_details?(@details)
        valid_email?(@emails)

        _details = @details
        _notify  = @notify
        _emails  = @emails
        _body    = render(_details[:body])

        Mail.new do
          from         _notify
          to           _details[:to] || _emails
          subject      _details[:subject]
          content_type 'text/html; charset=UTF-8'
          body         _body
        end.deliver!
      end

      private
      def render(data)
        if data.is_a?(Hash)
          renderor = Renderor.new(title: 'title', body: 'body')
          renderor.render
        else
          data
        end
      end

      def tempalte_file
        File.join('email-basic-html.mustache')
        File.dirname
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
    end
  end
end