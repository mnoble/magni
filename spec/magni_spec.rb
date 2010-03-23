require File.dirname(__FILE__) + '/spec_helper'

describe Magni do
  
  before :each do
    @test = Test.new
  end
  
  it "should map string flags to a type" do
    Test.mappings['boolean'].should == :boolean
  end
  
  it "should process a boolean" do
    @test.process("boolean", [])
    @test.options[:boolean].should == true
  end
  
  it "should process an integer" do
    @test.process("integer", ["2"])
    @test.options[:integer].should == 2
  end
  
  it "should process an array" do
    @test.process("array", ["a", "b", "c"])
    @test.options[:array].should == ["a", "b", "c"]
  end
  
  it "should process a string" do
    @test.process("string", ["hello"])
    @test.options[:string].should == "hello"
  end
  
  it "should accept multiple arguments" do
    test = Test.new(["--integer=9", "--string=wing", "--array=1,2,3,4"])
    test.options[:integer].should == 9
    test.options[:string].should == "wing"
    test.options[:array].should == [1, 2, 3, 4]
  end
  
end