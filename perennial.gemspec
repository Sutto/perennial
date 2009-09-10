# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{perennial}
  s.version = "0.2.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2009-09-11}
  s.default_executable = %q{perennial}
  s.description = %q{Perennial is a platform for building different applications in Ruby. It uses a controller-based approach with mixins to provide different functionality.}
  s.email = %q{sutto@sutto.net}
  s.executables = ["perennial"]
  s.files = ["bin/perennial", "vendor/fakefs", "vendor/fakefs/lib", "vendor/fakefs/lib/fakefs.rb", "vendor/fakefs/LICENSE", "vendor/fakefs/Rakefile", "vendor/fakefs/README.markdown", "vendor/fakefs/test", "vendor/fakefs/test/fakefs_test.rb", "vendor/fakefs/test/verify.rb", "lib/perennial", "lib/perennial/application.rb", "lib/perennial/argument_parser.rb", "lib/perennial/core_ext", "lib/perennial/core_ext/attribute_accessors.rb", "lib/perennial/core_ext/blank.rb", "lib/perennial/core_ext/hash_key_conversions.rb", "lib/perennial/core_ext/inflections.rb", "lib/perennial/core_ext/misc.rb", "lib/perennial/core_ext/proxy.rb", "lib/perennial/core_ext.rb", "lib/perennial/daemon.rb", "lib/perennial/delegateable.rb", "lib/perennial/dispatchable.rb", "lib/perennial/exceptions.rb", "lib/perennial/generator.rb", "lib/perennial/hookable.rb", "lib/perennial/loader.rb", "lib/perennial/loggable.rb", "lib/perennial/logger.rb", "lib/perennial/manifest.rb", "lib/perennial/option_parser.rb", "lib/perennial/settings.rb", "lib/perennial.rb", "test/delegateable_test.rb", "test/dispatchable_test.rb", "test/hookable_test.rb", "test/loader_test.rb", "test/loggable_test.rb", "test/logger_test.rb", "test/proxy_test.rb", "test/settings_test.rb", "test/test_helper.rb", "templates/application.erb", "templates/boot.erb", "templates/rakefile.erb", "templates/setup.erb", "templates/test.erb", "templates/test_helper.erb"]
  s.homepage = %q{http://sutto.net/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple (generally event-oriented) application library for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
