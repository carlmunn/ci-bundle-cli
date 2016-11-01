$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ci_bundle/cli"

Mail.defaults do
  delivery_method :test
end