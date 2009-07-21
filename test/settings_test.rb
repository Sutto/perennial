require File.join(File.dirname(__FILE__), "test_helper")

class SettingsTest < Test::Unit::TestCase
  
  context 'default settings' do
    
    setup do
      
    end
    
    should "default the application root to the parent folder of perennial"
    
    should "default daemonized to false"
    
  end
  
  context 'loading settings' do
    
    setup do
      config_folder = Perennial::Settings.root / "config"
      @default_settings = {
        "default" => {
          "introduction" => true,
          "description"  => "Ninjas are Totally Awesome",
          "channel"      => "#offrails",
          "users"        => ["Sutto", "njero", "zapnap"]
        }
      }
      FileUtils.mkdir_p(config_folder)
      File.open(config_folder / "settings.yml", "w+") do |file|
        file.write(@default_settings.to_yaml)
      end
      Perennial::Settings.setup!
    end
    
    should 'load settings from the file' do
      assert Perennial::Settings.setup?
      assert_equal @default_settings["default"].symbolize_keys, Perennial::Settings.to_hash
    end
    
    should 'define readers for the settings' do
      instance = Perennial::Settings.new
      @default_settings["default"].each_pair do |key, value|
        assert Perennial::Settings.respond_to?(key.to_sym)
        assert_equal value, Perennial::Settings.send(key)
        assert instance.respond_to?(key.to_sym)
        assert_equal value, instance.send(key)
      end
    end
    
    should 'let you access settings via hash-style accessors' do
      @default_settings["default"].each_pair do |key, value|
        assert_equal value, Perennial::Settings[key]
        Perennial::Settings[key] = "a-new-value from #{value.inspect}"
        assert_equal "a-new-value from #{value.inspect}", Perennial::Settings[key]
      end
    end
    
    should 'define writers for the settings' do
      instance = Perennial::Settings.new
      @default_settings["default"].each_pair do |key, value|
        setter = :"#{key}="
        assert Perennial::Settings.respond_to?(setter)
        Perennial::Settings.send(setter, "value #{value.inspect} on class")
        assert_equal "value #{value.inspect} on class", Perennial::Settings.send(key)
        assert instance.respond_to?(setter)
        instance.send(setter, "value #{value.inspect} on instance")
        assert_equal "value #{value.inspect} on instance", instance.send(key)
      end
    end
    
  end
  
end