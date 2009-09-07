require File.join(File.dirname(__FILE__), "test_helper")

class LoggerTest < Test::Unit::TestCase
  context 'logger tests' do
    
    setup do
      @root_path = Perennial::Settings.root / "log"
      Perennial::Logger.log_name = "example.log"
      FileUtils.mkdir_p @root_path
    end
  
    context 'setting up a logger' do
    
      setup { Perennial::Logger.setup! }
    
      should 'create the log file file after writing' do
        Perennial::Logger.fatal "Blergh."
        assert File.exist?(@root_path / "example.log")
      end
    
      Perennial::Logger::LEVELS.each_key do |level_name|
        should "define a method for the #{level_name} log level" do
          assert Perennial::Logger.respond_to?(level_name)
          assert Perennial::Logger.logger.respond_to?(level_name)
          assert_equal 1, Perennial::Logger.logger.method(level_name).arity
        end
      end
    
      should 'have a log exception method' do
        assert Perennial::Logger.respond_to?(:log_exception)
        assert Perennial::Logger.logger.respond_to?(:log_exception)
      end
      
      should 'let you configure a dir that logs are loaded from'
    
    end
  
    context 'writing to the log' do
      
      Perennial::Logger::LEVELS.each_key do |level_name|
        should "let you write to the #{level_name} log level" do
          Perennial::Logger.verbose = false
          Perennial::Logger.level = level_name
          assert_nothing_raised do
            Perennial::Logger.logger.send(level_name, "An Example Message No. 1")
          end
        end
      end
      
    end
  
    teardown do
      log_path = @root_path / "example.log"
      FileUtils.rm_rf(log_path) if File.exist?(log_path)
    end
    
  end
  
end