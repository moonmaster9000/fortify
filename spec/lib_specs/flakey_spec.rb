require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "an ActiveResource::Base derived class" do
  before do
    class Book < ActiveResource::Base
    end
  end
  
  describe "flakey class method" do
    it "should not throw an error when you call flakey" do
      proc {
        Book.flakey
      }.should_not raise_error
    end
  
    it "should not thrown an error when you pass a block to flakey" do
      proc {
        Book.flakey do |fortify|
        end
      }.should_not raise_error
    end
  end
end