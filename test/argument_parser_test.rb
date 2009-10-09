require File.join(File.dirname(__FILE__), "test_helper")

require 'shellwords'

class ArgumentParserTest < Test::Unit::TestCase
  
  context 'simple argument parsing' do
    
    should 'correct parse arguments using no options' do
      args, hash = parse("a b c")
      assert_equal({}, hash)
      assert_equal ["a", "b", "c"], args
    end
    
    should 'correct parse arguments using only short formats' do
      args, hash = parse("-a -b=1 -c 3")
      assert_equal [], args
      assert_equal({"a" => true, "b" => "1", "c" => "3"}, hash)
    end
    
    should 'correct parse arguments using only long format' do
      args, hash = parse("--ninjas --rockn=roll --awesome sauce")
      assert_equal [], args
      assert_equal({
        "ninjas"  => true,
        "rockn"   => "roll",
        "awesome" => "sauce"
      }, hash)
    end
    
    should 'correct parse arguments using mixed arguments' do
    args, hash = parse("client --verbose --l=debug --user sutto another-arg")
    assert_equal ["client", "another-arg"], args
    assert_equal({
      "verbose" => true,
      "l"       => "debug",
      "user"    => "sutto"
    }, hash)
    end
    
    should 'correct differentiate between --value=a and --value b' do
      args, hash = parse("--felafel value beat")
      assert_equal ["beat"], args
      assert_equal({"felafel" => "value"}, hash)
      args, hash = parse("--felafel=value beat")
      assert_equal ["beat"], args
      assert_equal({"felafel" => "value"}, hash)
    end
    
  end
  
  def parse(s)
    Perennial::ArgumentParser.parse Shellwords.shellwords(s)
  end
  
end