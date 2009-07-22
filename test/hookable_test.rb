require File.join(File.dirname(__FILE__), "test_helper")

class HookableTest < Test::Unit::TestCase
  
  context 'Hookable Classes' do
    
    setup do
      @hookable_class = test_class_for(Perennial::Hookable)
    end
    
    should 'let you append hooks via append_hook' do
      assert_equal [], @hookable_class.hooks_for(:awesome)
      @hookable_class.append_hook(:awesome) { puts "Hello!" }
      assert_equal 1, @hookable_class.hooks_for(:awesome).size
    end
    
    should 'only append hooks if they aren\'t blank' do
      @hookable_class.append_hook(:awesome)
      assert_equal [], @hookable_class.hooks_for(:awesome)
    end
    
    should 'let you get an array of hooks' do
      @hookable_class.append_hook(:awesome) { puts "A" }
      @hookable_class.append_hook(:awesome) { puts "B" }
      assert_equal 2, @hookable_class.hooks_for(:awesome).size
    end
    
    should 'let you invoke hooks' do
      items = []
      @hookable_class.append_hook(:awesome) { items << :a }
      @hookable_class.append_hook(:awesome) { items << :b }
      @hookable_class.append_hook(:awesome) { items << :c }
      @hookable_class.invoke_hooks!(:awesome)
      assert_equal [:a, :b, :c], items
    end
    
    should 'call them in the order they are appended' do
      items = []
      @hookable_class.append_hook(:awesome) { items << :a }
      @hookable_class.append_hook(:awesome) { items << :b }
      @hookable_class.append_hook(:awesome) { items << :c }
      @hookable_class.invoke_hooks!(:awesome)
      [:a, :b, :c].each_with_index do |value, index|
        assert_equal value, items[index]
      end
    end
    
    should 'let you define hook accessors' do
      assert_equal [], @hookable_class.hooks_for(:awesome)
      assert !@hookable_class.respond_to?(:awesome)
      assert !@hookable_class.respond_to?(:sauce)
      @hookable_class.define_hook :awesome, :sauce
      assert @hookable_class.respond_to?(:awesome)
      assert @hookable_class.respond_to?(:sauce)
      @hookable_class.awesome { puts "A" }
      assert_equal 1, @hookable_class.hooks_for(:awesome).size
    end
    
  end
  
end