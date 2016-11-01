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
        
        _log "RUBY: #{`ruby -v`.chomp}"

        begin
          _log "CMD: #{cmd}"

          out_str, err_str, status = Open3.capture3(cmd)

          _log "CMD status: #{status}"

          #raise(CiFailureExp, "Errors from Open3: #{err_str}") if status != 0 && _present?(err_str)

          out_str
        rescue => err
          _process_exception(err); ""
        end
      end

      def _log(msg)
        CiBundle::Cli.log(msg)
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
        File.basename(@opts[:file]) if @opts[:file]
      end

      def _pwd
        File.absolute_path(File.dirname(@opts[:file])) if @opts[:file]
      end

      def _path
        File.absolute_path(@opts[:path]) if @opts[:path]
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