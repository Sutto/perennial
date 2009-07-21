require File.join(File.dirname(__FILE__), "test_helper")

class SettingsTest < Test::Unit::TestCase
  
  context 'default settings' do
    
    should "default the application root to the parent folder of perennial"
    
    should "default daemonized to false"
    
  end
  
  context 'loading settings' do
  end
  
end