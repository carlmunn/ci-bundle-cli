require 'byebug'
require 'open3'

module CiBundle
  module Cli
    # Supply basic commands that will be used all
    class BaseCommand

      CMDS_LOOKUP = {
        'bundle-update': 'bundle update',
        'rails-update': 'rake db:migrate',
        'svn-update': 'svn update',
        'git-update': 'git pull'
      }

      def initialize(opts={})
        @opts    = opts

        # TODO: These could be extracted out into their own gems
        @notifier = CiBundle::Cli::Notifier.new(opts)
        @parser   = CiBundle::Cli::Parser.new(opts)
      end

      private
      def run_command(cmd)
        _log "Command: #{cmd}"[0..256]

        out_str, err_str, status = Open3.capture3(cmd)

        _log "status:#{status}"

        _process_error(err_str) if err_str

        out_str
      end

      def _log(msg)
        puts "[D] #{msg}" if @opts[:verbose]
      end

      def pre_run_commands
        check_option(:run)
        @opts[:run].map {|cmd| CMDS_LOOKUP[cmd] }.compact
      end

      # The result might be XML or JSON. tidy it so we can send it in an email
      def parse(result, input_type: nil)
        @parser ? @parser.process(result, input_type: input_type) : result
      end

      def notify(result, by: nil)
        @notifier.process(result, by: by)
      end

      def _basename
        check_option(:file)
        File.basename(@opts[:file])
      end

      def _pwd
        check_option(:file)
        File.absolute_path(File.dirname(@opts[:file]))
      end

      def _path
        check_option(:path)
        File.absolute_path(@opts[:path])
      end

      def check_option(name)
        raise "Option '#{name}' was not supplied" unless @opts[name]
      end

      def _process_error(err)
        warn(err)

        _data = {subject: 'Test Error for XXX', body: err}
        _opts = {notify: @opts[:notify]}

        CiBundle::Cli::Mailer.new(_data, opts: _opts).deliver!
      end
    end
  end
end