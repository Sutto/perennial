# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{perennial}
  s.version = "1.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2010-01-03}
  s.default_executable = %q{perennial}
  s.description = %q{Perennial is a platform for building different applications in Ruby. It uses a controller-based approach with mixins to provide different functionality.}
  s.email = %q{sutto@sutto.net}
  s.executables = ["perennial"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "bin/perennial",
     "lib/perennial.rb",
     "lib/perennial/application.rb",
     "lib/perennial/argument_parser.rb",
     "lib/perennial/core_ext.rb",
     "lib/perennial/core_ext/ansi_formatter.rb",
     "lib/perennial/core_ext/attribute_accessors.rb",
     "lib/perennial/core_ext/blank.rb",
     "lib/perennial/core_ext/hash_key_conversions.rb",
     "lib/perennial/core_ext/inflections.rb",
     "lib/perennial/core_ext/instance_exec.rb",
     "lib/perennial/core_ext/misc.rb",
     "lib/perennial/core_ext/proxy.rb",
     "lib/perennial/daemon.rb",
     "lib/perennial/delegateable.rb",
     "lib/perennial/dispatchable.rb",
     "lib/perennial/exceptions.rb",
     "lib/perennial/generator.rb",
     "lib/perennial/hookable.rb",
     "lib/perennial/jeweler_ext.rb",
     "lib/perennial/loader.rb",
     "lib/perennial/loggable.rb",
     "lib/perennial/logger.rb",
     "lib/perennial/manifest.rb",
     "lib/perennial/nash.rb",
     "lib/perennial/option_parser.rb",
     "lib/perennial/protocols.rb",
     "lib/perennial/protocols/json_transport.rb",
     "lib/perennial/protocols/pure_ruby.rb",
     "lib/perennial/protocols/pure_ruby/json_transport.rb",
     "lib/perennial/reloading.rb",
     "lib/perennial/settings.rb",
     "templates/application.erb",
     "templates/boot.erb",
     "templates/rakefile.erb",
     "templates/setup.erb",
     "templates/test.erb",
     "templates/test_helper.erb"
  ]
  s.homepage = %q{http://sutto.net/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple (generally event-oriented) application library for Ruby}
  s.test_files = [
    "test/argument_parser_test.rb",
     "test/delegateable_test.rb",
     "test/dispatchable_test.rb",
     "test/generator_test.rb",
     "test/hookable_test.rb",
     "test/loader_test.rb",
     "test/loggable_test.rb",
     "test/logger_test.rb",
     "test/option_parser_test.rb",
     "test/proxy_test.rb",
     "test/reloading_test.rb",
     "test/settings_test.rb",
     "test/test_helper.rb",
     "examples/json_echo_client.rb",
     "examples/json_echo_server.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

