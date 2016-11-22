#encoding: utf-8

require 'open3'
require 'cgi'
require 'mail'
require 'mustache'
require 'json'

require "ci_bundle/cli/version"
require "ci_bundle/cli/commands"
require "ci_bundle/cli/notifier"
require "ci_bundle/cli/email"
require "ci_bundle/cli/parser"
require "ci_bundle/cli/run_command"
require "ci_bundle/cli/rspec_command"

_major, _minor = RUBY_VERSION.split('.').map(&:to_i)

above19 = _major == 1 && _minor >= 9
above2  = _major >= 2

if above19 || above2
  # RSpec was giving JSON that wasn't UTF-8 friendly
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

module CiBundle
  module Cli
    def self.run(command, opts={})
      @opts = opts
      const_get("#{command.capitalize}Command").new(opts).run
    end

    # TODO: Still working on a decent logger
    def self.log(msg)
      puts "[D] #{msg}" if (@opts && @opts[:verbose])
    end
  end
end
