# frozen_string_literal: true

require_relative "lib/lc3/version"

Gem::Specification.new do |spec|
  spec.name = "lc3"
  spec.version = LC3::VERSION
  spec.authors = ["CJ Joel"]
  spec.email = ["cjjoel5@gmail.com"]

  spec.summary = "Virtual Machine for LC3"
  spec.homepage = "https://github.com/cjjoel/lc3"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.executables = ["lc3"]
  spec.require_paths = ["lib"]
end
