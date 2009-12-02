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
    describe "when passed a block" do
      it "should not require a block be passed to it" do
        proc { Book.fortify }.should_not raise_error
      end
  
      it "should require the block passed to it accept one argument" do
        proc { Book.fortify {} }.should raise_error(BlockArgumentError)
      end
    
      it "should pass a default attributes class to the block" do
        Book.fortify do |default_attributes|
          default_attributes.class.should == DefaultAttributes
        end
      end
    end
    
    describe "when passed one or more nonhash parameters" do
      it "should throw an error unless all the paramters are symbols" do
        proc { Book.fortify :author, :genre, :isbn }.should_not raise_error
        proc { Book.fortify :author, :isbn, :genre => 'fiction'}.should raise_error(ArgumentError)
        proc { Book.fortify :author}.should_not raise_error
      end
      
      it "should add nil default attributes for each symbol passed to it" do
        Book.fortify :author, :genre, :isbn
        Book.default_attributes.attributes.has_key?(:author).should be_true
        Book.default_attributes.attributes[:author].should be_nil
        Book.default_attributes.attributes.has_key?(:genre).should be_true
        Book.default_attributes.attributes[:genre].should be_nil
        Book.default_attributes.attributes.has_key?(:isbn).should be_true
        Book.default_attributes.attributes[:isbn].should be_nil
      end
    end
    
    describe "when passed a single hash" do
      it "should not throw an error" do
        proc {Book.fortify :author => 'Anonymous'}.should_not raise_error
      end
      
      it "should add default attributes based on the hash" do
        Book.fortify :author => 'Anonymous', :genre => 'fiction'
        Book.default_attributes.attributes.has_key?(:author).should be_true
        Book.default_attributes.attributes[:author].should == 'Anonymous'
        Book.default_attributes.attributes.has_key?(:genre).should be_true
        Book.default_attributes.attributes[:genre].should == 'fiction'
      end
    end
  end
  
  describe "new" do
    describe "when fortified with a block" do
      before do
        Book.fortify do |default_attributes|
          default_attributes.author = 'Anonymous'
          default_attributes.genre  = 'Fiction'
          default_attributes.isbn  
        end        
      end
      
      it "should use the default attributes created via fortify" do
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
    
    describe "when fortified with symbols" do
      before do
        Book.fortify :author, :genre, :isbn
      end
      
      it "should use the default attributes created via fortify" do
        b = Book.new
        proc {b.author}.should_not raise_error
        b.author.should be_nil
        proc {b.genre}.should_not raise_error
        b.genre.should be_nil
        proc {b.isbn}.should_not raise_error
        b.isbn.should be_nil
        proc {b.attribute_not_appearing_in_this_test}.should raise_error
      end
    end
    
    describe "when fortified with a hash" do
      before do
        Book.fortify :author => 'Anonymous', :genre => 'Fiction', :isbn => '0000'
      end
      
      it "should use the default attributes created via fortify" do
        b = Book.new

        proc {b.author}.should_not raise_error
        b.author.should == 'Anonymous'
        proc {b.genre}.should_not raise_error
        b.genre.should == 'Fiction'
        proc {b.isbn}.should_not raise_error
        b.isbn.should == '0000'
        proc {b.attribute_not_appearing_in_this_test}.should raise_error
      end
    end
    
  end
end