# frozen_string_literal: true

require_relative "lib/bluetooth/device/picker/version"

Gem::Specification.new do |spec|
  spec.name = "bluetooth-device-picker"
  spec.version = Bluetooth::Device::Picker::VERSION
  spec.authors = ["Aaron Rustad"]
  spec.email = ["arustad@anassina.com"]

  spec.summary = "A command-line tool to connect and disconnect Bluetooth devices on macOS"
  spec.description = <<~DESC.strip
    Bluetooth Device Picker provides an interactive CLI for managing Bluetooth
    device connections on macOS using blueutil. Features include device listing
    with connection status, filtering, and quick toggle functionality.
  DESC
  spec.homepage = "https://github.com/AaronRustad/bluetooth-device-picker"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/AaronRustad/bluetooth-device-picker"
  spec.metadata["changelog_uri"] = "https://github.com/AaronRustad/bluetooth-device-picker/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "pastel"
  spec.add_dependency "tty-command"
  spec.add_dependency "tty-prompt", "~> 0.23"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
