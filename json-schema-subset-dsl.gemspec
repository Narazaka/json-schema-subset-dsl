lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "json/schema/subset/dsl/version"

Gem::Specification.new do |spec|
  spec.name = "json-schema-subset-dsl"
  spec.version = Json::Schema::Subset::DSL::VERSION
  spec.authors = %w[Narazaka]
  spec.email = %w[info@narazaka.net]
  spec.licenses = %w[Zlib]

  spec.summary = "Yet another JSON Schema subset DSL"
  spec.description = "Useful when writing a simple JSON schema."
  spec.homepage = "https://github.com/#{spec.authors.first}/#{spec.name}"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path("..", __FILE__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rspec-power_assert", "~> 1.1"
  spec.add_development_dependency "rubocop", "~> 0.76"
  spec.add_development_dependency "rubocop-airbnb", "~> 3"
  spec.add_development_dependency "prettier", ">= 0.16"
  spec.add_development_dependency "rubocop-config-prettier", "~> 0.1"
  spec.add_development_dependency "pry-byebug", "~> 3.7"
  spec.add_development_dependency "yard", "~> 0.9"
end
