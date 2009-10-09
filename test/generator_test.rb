require File.join(File.dirname(__FILE__), "test_helper")

class GeneratorTest < Test::Unit::TestCase
  context 'a basic generator' do
    
    setup do
      @generator_dir = Pathname(__FILE__).dirname.join("..", "generator-test").expand_path
      FileUtils.mkdir_p(@generator_dir)
      @generator = Perennial::Generator.new(@generator_dir, :silent => true)
    end
    
    should 'let you create folders' do
      assert !File.directory?(File.join(@generator_dir, "test-a"))
      assert !File.directory?(File.join(@generator_dir, "test-b"))
      assert !File.directory?(File.join(@generator_dir, "test-c"))
      assert !File.directory?(File.join(@generator_dir, "test-c/subdir"))
      @generator.folders 'test-a', 'test-b', 'test-c/subdir'
      assert File.directory?(File.join(@generator_dir, "test-a"))
      assert File.directory?(File.join(@generator_dir, "test-b"))
      assert File.directory?(File.join(@generator_dir, "test-c"))
      assert File.directory?(File.join(@generator_dir, "test-c/subdir"))
    end
    
    should 'define a shortcut for FileUtils' do
      assert_equal FileUtils, @generator.fu
    end
    
    should 'let you chmod a file' do
      test_file = Pathname(@generator_dir).join("test-file").expand_path
      File.open(test_file, "w+") { |f| f.puts "Some Simple File" }
      old_permissions = File.stat(test_file).mode
      @generator.chmod 0755, "test-file"
      new_permissions = File.stat(test_file).mode
      assert_not_equal old_permissions, new_permissions
      assert_equal 0100755, new_permissions
    end
    
    should 'let you easily check if a file exists' do
      assert !@generator.file?("test-file")
      test_file = Pathname(@generator_dir).join("test-file").expand_path
      File.open(test_file, "w+") { |f| f.puts "Some Simple File" }
      assert @generator.file?("test-file")
    end
    
    should 'let you easily check if a directory exists' do
      assert !@generator.directory?("test-dir")
      FileUtils.mkdir Pathname(@generator_dir).join("test-dir").expand_path
      assert @generator.directory?("test-dir")
    end
    
    should 'let you easily check if a file is executable' do
      test_file = Pathname(@generator_dir).join("test-file").expand_path
      File.open(test_file, "w+") { |f| f.puts "#!/bin/sh" }
      assert !@generator.executable?("test-file")
      File.chmod 0755, test_file
      assert @generator.executable?("test-file")
    end
    
    should 'let you generate a file with contents' do
      test_file = Pathname(@generator_dir).join("test-file").expand_path
      @generator.file("test-file", "Example File")
      assert_equal "Example File", File.read(test_file)
      @generator.file("test-file", "Example File 2")
      assert_equal "Example File 2", File.read(test_file)
    end
    
    should 'let you generate a file with contents, possibly appending' do
      test_file = Pathname(@generator_dir).join("test-file").expand_path
      @generator.file("test-file", "Example File")
      assert_equal "Example File", File.read(test_file)
      @generator.file("test-file", " 2", true)
      assert_equal "Example File 2", File.read(test_file)
    end
    
    should 'let you render a template' do
      test_file = @generator_dir.join("test-file").expand_path
      template_dir = @generator_dir.join("templates")
      FileUtils.mkdir_p template_dir
      File.open(template_dir.join("sample.erb"), "w+") { |f| f.puts "Hello <%= @name %>" }
      @generator.template_path = template_dir.to_s
      assert !File.file?(test_file)
      @generator.template "sample.erb", "test-file", :name => "Darcy"
      assert File.file?(test_file)
      assert_equal "Hello Darcy", File.read(test_file).strip
    end
    
    should 'let you download file and save it'
    
    teardown do
      FileUtils.rm_rf(@generator_dir) if File.directory?(@generator_dir)
    end
    
  end
end