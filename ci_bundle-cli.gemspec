# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ci_bundle/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "ci_bundle-cli"
  spec.version       = CiBundle::Cli::VERSION
  spec.authors       = ["Carl Munn"]
  spec.email         = ["carl.munn@open2view.com"]

  spec.summary       = %q{Helps with running tests and sending out email about failures}
  spec.description   = %q{Replacement for a simple script that did this but got out of hand so I decided to restructure}
  spec.homepage      = "https://github.com/carlmunn/ci-bundle-cli"
  spec.licenses      = ['MIT']

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Script seems to still require these gems when calling the 'bin'
  # Need to `bundle` this gem using the same ruby version as the tests
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  
  spec.add_development_dependency "byebug", "> 0"

  spec.add_dependency "slop", "~> 4.0"
  spec.add_dependency "mail", "~> 2.0"
  spec.add_dependency "mustache", "~> 1.0"
end
