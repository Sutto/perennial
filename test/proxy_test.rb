require File.join(File.dirname(__FILE__), "test_helper")

class ProxyTest < Test::Unit::TestCase
  
  context 'basic proxies' do
    
    setup do
      @proxy = Perennial::Proxy.new
      @proxy.__proxy_target__ = :awesome
    end    
    should 'pass through the correct class' do
      assert_equal Symbol, @proxy.class
      assert_kind_of Symbol, @proxy
    end
    
    should 'not interfere with equals' do
      assert @proxy  == :awesome
    end
    
    should 'pass through to_s' do
      assert_equal "awesome", @proxy.to_s
    end
    
    should 'let you send to an object' do
      assert_equal "awesome", @proxy.send(:to_s)
    end
    
  end
  
end