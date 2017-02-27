module CiBundle
  module Cli
    # Supply basic commands that will be used all
    class BaseCommand
      
      class CiFailureExp < StandardError; end

      # FreeBSD
      NULL_DEV = "/dev/null"

      CMDS_LOOKUP = {
        'bundle-update': "bundle update",
        'bundle': "bundle",
        'rails-migrate': "RAILS_ENV=test bundle exec rake db:migrate",
        'svn-update': "svn update",
        'git-update': "git pull"
      }

      def initialize(opts={})
        @opts     = opts

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

          _log "CMD error: #{err_str}" if err_str && err_str.length > 1

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
        @opts[:run].map do |cmd|
          _cmd = CMDS_LOOKUP[cmd.to_sym]

          _cmd = "#{_cmd} >#{NULL_DEV}" #@opts[:verbose]

          if @opts[:log]
            "#{_cmd} > #{log_file(cmd)}"
          else
            _cmd
          end
        end.compact if @opts[:run]
      end

      def log_file(cmd_name)

        ns   = @opts[:namespace]
        date = Time.now.strftime("%Y-%m-%d_%H%M%S")

        file_name = ['tests'].tap do |ary|
          ary << ns.gsub(/\[\]/, '-').downcase if ns
          ary << date
          ary << cmd_name.gsub(/\s/, '_').downcase
        end.join("_")
        
        "#{file_name}.log"
      end

      # The result might be XML or JSON. tidy it so we can send it in an email
      def parse(result, input_type: nil)
        @parser ? @parser.process(result, input_type: input_type) : result
      end

      def notify(result, by: nil)
        @notifier.notify_success(result, by: by)
      end

      def _basename
        File.basename(@opts[:file].first) if @opts[:file].first
      end

      def _pwd
        File.absolute_path(File.dirname(@opts[:file].first)) if @opts[:file].first
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