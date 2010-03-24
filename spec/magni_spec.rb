require File.dirname(__FILE__) + '/spec_helper'

describe Magni do
  
  before :each do
    @test = Test.new
  end
  
  describe "mappings" do
    it "should map to :boolean" do
      Test.mappings['boolean'].should == :boolean
    end
    
    it "should map to :integer" do
      Test.mappings['integer'].should == :integer
    end
    
    it "should map to :string" do
      Test.mappings['string'].should == :string
    end
    
    it "should map to :array" do
      Test.mappings['array'].should == :array
    end
  end
  
  describe "booleans" do
    it "should be processes into a boolean" do
      @test.process("boolean", [])
      @test.options[:boolean].should == true
    end
    
    it "should raise an error when passed a value" do
      lambda { Test.new(["--boolean=wrong"]) }.should raise_error
    end
  end
  
  describe "integers" do
    it "should be processes into a fixnum" do
      @test.process("integer", ["2"])
      @test.options[:integer].should == 2
    end
    
    it "should raise an error when passed a string" do
      lambda { Test.new(["--integer=abc"]) }.should raise_error
    end
  end
  
  describe "strings" do
    it "should be processes into a string" do
      @test.process("string", ["hello"])
      @test.options[:string].should == "hello"
    end
    
    it "should raise an error when passed an array" do
      lambda { Test.new(["--string=a,b,c"]) }.should raise_error
    end
  end
  
  describe "arrays" do
    it "should be processes into an array" do
      @test.process("array", ["a", "b", "c"])
      @test.options[:array].should == ["a", "b", "c"]
    end
    
    it "should raise an error when no values are received" do
      lambda { Test.new(["--array"]) }.should raise_error
    end
  end
  
  it "should accept multiple arguments" do
    test = Test.new(["--integer=9", "--string=wing", "--array=1,2,3,4"])
    test.options[:integer].should == 9
    test.options[:string].should == "wing"
    test.options[:array].should == [1, 2, 3, 4]
  end
  
  it "should silently ignore non-flag command line arguments" do
    lambda { Test.new(["omgdontfail", "whatthe"]) }.should_not raise_error
  end
  
  it "should not set non-flag arguments in options" do
    test = Test.new(["omgdontfail"])
    test.options.should be_empty
  end
  
  it "should delegate to the class given" do
    class Controller; def invoke; end; end
    controller = Controller.new
    Controller.stub!(:new).and_return(controller)
    
    controller.should_receive(:invoke)
    Magni.delegate_to(Controller, :invoke)
  end
  
end