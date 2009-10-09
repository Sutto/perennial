require File.join(File.dirname(__FILE__), "test_helper")

class ReloadingTest < Test::Unit::TestCase
  
  context 'basic reloading file' do
    
    setup do
      @file = File.join(File.dirname(__FILE__), "tmp", "reloading_test.rb")
      FileUtils.mkdir_p File.dirname(@file)
      write_reloadable_klass(:initial)
      load @file
      Perennial::Reloading.watch @file
      ReloadingTest.count = 10
    end
    
    should 'call reloading on the old class if defined' do
      ReloadingTest.expects(:respond_to?).with(:reloading!).returns(true)
      ReloadingTest.expects(:reloading!)
      write_reloadable_klass :reloaded
      Perennial::Reloading.reload!
    end
    
    should 'call reloaded if defined' do
      assert !ReloadingTest.was_reloaded
      # Reload without the method
      write_reloadable_klass :reloaded
      Perennial::Reloading.reload!
      assert !ReloadingTest.was_reloaded
      # finally, define the method and reload.
      write_reloadable_klass :reloaded, true
      Perennial::Reloading.reload!
      assert ReloadingTest.was_reloaded
    end
    
    should 'reload if changed' do
      assert_equal 10, ReloadingTest.count
      assert_equal :initial, ReloadingTest::RELOADED_VALUE
      write_reloadable_klass :reloaded
      Perennial::Reloading.reload!
      assert_equal 0, ReloadingTest.count
      assert_equal :reloaded, ReloadingTest::RELOADED_VALUE
    end
    
    should 'not reload if unchanged' do
      assert_equal 10, ReloadingTest.count
      assert_equal :initial, ReloadingTest::RELOADED_VALUE
      Perennial::Reloading.reload!
      assert_equal 10, ReloadingTest.count
      assert_equal :initial, ReloadingTest::RELOADED_VALUE
    end
    
    teardown do
      File.delete @file if File.exist?(@file)
      Object.send(:remove_const, :ReloadingTest) if defined?(ReloadingTest)
    end
    
  end
  
  def write_reloadable_klass(value, include_reloaded = false)
    u, a = Time.now, Time.now
    u, a = File.atime(@file), File.mtime(@file) if File.exist?(@file)
    File.open(@file, "w+") do |f|
      f.puts "class ReloadingTest"
      f.puts "  RELOADED_VALUE = #{value.inspect}"
      f.puts "  cattr_accessor :count"
      f.puts "  self.count = 0"
      f.puts "  cattr_reader :was_reloaded"
      f.puts "  def self.reloaded!; @@was_reloaded = true; end" if include_reloaded
      f.puts "end"
    end
    # We fake the mtime to simulate a proper, delay
    File.utime(u + 3, a + 3, File.expand_path(@file))
  end
  
end