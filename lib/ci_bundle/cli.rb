require "ci_bundle/cli/version"
require "ci_bundle/cli/commands"
require "ci_bundle/cli/notifier"
require "ci_bundle/cli/email"
require "ci_bundle/cli/parser"
require "ci_bundle/cli/run_command"
require "ci_bundle/cli/rspec_command"

module CiBundle
  module Cli
    def self.run(command, opts={})
      const_get("#{command.capitalize}Command").new(opts).run
    end

    # TODO: Still working on a decent logger
    def self.log(msg)
      puts "[D] #{msg}" if (@opts && @opts[:verbose])
    end
  end
end
