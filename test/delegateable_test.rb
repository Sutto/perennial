require File.join(File.dirname(__FILE__), "test_helper")

class DelegateableTest < Test::Unit::TestCase
  
  context 'basic delegates' do
    
    setup do
      @klass = test_class_for(Perennial::Delegateable)
      @delegateable = @klass.new
    end
    
    should 'define a delegate= method' do
      assert @delegateable.respond_to?(:delegate=)
    end
    
    should 'define a delegate_to method' do
      assert @delegateable.respond_to?(:delegate_to)
    end
    
    should 'let you get the delegate proxy' do
      @delegateable.delegate_to :awesome
      assert proxy = @delegateable.delegate
      assert_nothing_raised { proxy.awesomesauce }
      assert_nothing_raised { proxy.ninja_party }
      assert_equal "awesome", proxy.to_s
    end
    
    should 'let you get the real target of the delegate' do
      @delegateable.delegate_to :awesome
      assert real = @delegateable.real_delegate
      assert_raises(NoMethodError) { real.awesomesauce }
      assert_raises(NoMethodError) { real.ninja_party }
      assert_equal "awesome", real.to_s
    end
    
  end
  
end