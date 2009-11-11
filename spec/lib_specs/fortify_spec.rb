require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ActiveResource::Base --" do
  before do
    class Book < ActiveResource::Base
      self.site = ''
    end
  end
  
  describe "default_attributes class method" do
    it "should return a DefaultAttributes class" do
      Book.default_attributes.class.to_s.should == "DefaultAttributes"
    end
  end
  
  describe "DefaultAttributes" do
    it "should have an attributes accessor" do
      proc {Book.default_attributes.attributes}.should_not raise_error
    end
    
    it "should support setting attributes via method missing" do
      proc {Book.default_attributes.author}.should_not raise_error
      Book.default_attributes.attributes.has_key?(:author).should be_true
    end
  end
  
  describe "fortify class method" do
    it "should require a block be passed to it" do
      proc { Book.fortify }.should raise_error(BlockRequiredError)
    end
  
    it "should require the block passed to it accept one argument" do
      proc { Book.fortify {} }.should raise_error(BlockArgumentError)
    end
    
    it "should pass a default attributes class to the block" do
      Book.fortify do |default_attributes|
        default_attributes.class.to_s.should == "DefaultAttributes"
      end
    end
  end
  
  describe "new" do
    it "should use the default attributes created via fortify" do
      Book.fortify do |default_attributes|
        default_attributes.author = 'Anonymous'
        default_attributes.genre  = 'Fiction'
        default_attributes.isbn  
      end
      
      b = Book.new
      
      proc {b.author}.should_not raise_error
      b.author.should == 'Anonymous'
      proc {b.genre}.should_not raise_error
      b.genre.should == 'Fiction'
      proc {b.isbn}.should_not raise_error
      b.isbn.should be_nil
      proc {b.attribute_not_appearing_in_this_test}.should raise_error
    end
  end
end