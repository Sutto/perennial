require File.join(File.dirname(__FILE__), "test_helper")
require 'shellwords'

class OptionParserTest < Test::Unit::TestCase
  context 'basic option parsing' do
    
    setup do
      @options = {}
      @option_parser = Perennial::OptionParser.new
      @option_parser.add(:age, "Your age") { |v| @options[:age] = v.to_i }
      @option_parser.add(:name, "Your name") { |v| @options[:name] = v.to_s }
      @option_parser.add(:ninja, "Are you a ninja") { |v| @options[:ninjas] = v.present? }
      @option_parser.add(:felafel, "Do you enjoy felafel?", :shortcut => "X") { |v| @options[:felafel] = v.present? }
    end
    
    should 'correct recognize short options' do
      parse! "-a 18 -n \"Darcy Laycock\" -N -X"
      assert_equal({
        :age => 18,
        :name => "Darcy Laycock",
        :ninjas => true,
        :felafel => true
      }, @options)
    end
    
    should 'correctly recognize long options' do
      parse! "--age 21 --name \"Darcy Laycock\" --ninja --felafel"
      assert_equal({
        :age => 21,
        :name => "Darcy Laycock",
        :ninjas => true,
        :felafel => true
      }, @options)
    end
    
    should 'correctly recognize mixed options' do
      parse! "-a 21 --name \"Darcy Laycock\" -N --felafel"
      assert_equal({
        :age => 21,
        :name => "Darcy Laycock",
        :ninjas => true,
        :felafel => true
      }, @options)
    end
      
  end
  
  def parse!(l)
    @option_parser.parse(Shellwords.shellwords(l))
  end
  
end