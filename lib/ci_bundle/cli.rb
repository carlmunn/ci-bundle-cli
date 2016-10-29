require "ci_bundle/cli/version"
require "ci_bundle/cli/commands"
require "ci_bundle/cli/notifier"
require "ci_bundle/cli/email"
require "ci_bundle/cli/parser"
require "ci_bundle/cli/run_command"
require "ci_bundle/cli/rspec_command"

module CiBundle
  module Cli
    def self.run(command, options={})
      const_get("#{command.capitalize}Command").new(options).run
    end
  end
end
