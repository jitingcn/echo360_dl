# frozen_string_literal: true

require_relative "lib/echo360_dl/version"

Gem::Specification.new do |spec|
  spec.name          = "echo360-dl"
  spec.version       = Echo360DL::VERSION
  spec.authors       = ["Jiting"]
  spec.email         = ["jiting@jtcat.com"]

  spec.summary       = "echo360 media downloader"
  spec.description   = "Download media from url like https://echo360.org[.*]/media/:uuid/public"
  spec.homepage      = "https://github.com/jitingcn/echo360-dl"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  # spec.metadata["allowed_push_host"] = "Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jitingcn/echo360_dl"
  spec.metadata["changelog_uri"] = "https://github.com/jitingcn/echo360_dl/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ruby-progressbar"
  spec.add_dependency "activesupport"
  spec.add_dependency "ferrum"
  spec.add_dependency "httparty"

  spec.add_development_dependency "debug"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
