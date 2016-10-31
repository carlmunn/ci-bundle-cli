require 'byebug'
require 'open3'
require 'cgi'

module CiBundle
  module Cli
    # Supply basic commands that will be used all
    class BaseCommand
      
      class CiFailureExp < StandardError; end

      CMDS_LOOKUP = {
        'bundle-update': 'bundle update',
        'rails-migrate': 'rake db:migrate',
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

        #raise(CiFailureExp, "Errors from Open3: #{err_str}") if status != 0 && _present?(err_str)

        out_str
      rescue => err
        _process_exception(err); ""
      end

      def _log(msg)
        puts "[D] #{msg}" if @opts[:verbose]
      end

      def pre_run_commands
        @opts[:run].map {|cmd| CMDS_LOOKUP[cmd.to_sym] }.compact if @opts[:run]
      end

      # The result might be XML or JSON. tidy it so we can send it in an email
      def parse(result, input_type: nil)
        @parser ? @parser.process(result, input_type: input_type) : result
      end

      def notify(result, by: nil)
        @notifier.notify_success(result, by: by)
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

      def _process_exception(exp)
        warn("[W] '#{exp}'")
        @notifier.notify_exception(exp)
      end

      def _present?(str)
        str && str.length >= 1
      end
    end
  end
end