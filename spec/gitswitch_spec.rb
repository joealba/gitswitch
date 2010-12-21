require 'spec_helper'

describe GitSwitch do

  describe "basics" do
    it "should have a VERSION" do
      VERSION.should_not == ''
    end

    it "should find the git executable" do
      result = %x[#{GitSwitch::GIT_BIN} --version]
      $?.exitstatus.should == 0
    end    
  end


  describe "read-only" do
    it "should show the current git user credentials" do
      GitSwitch.current_user_info.should =~ /^Current git user info/
    end
  end


  describe "write methods" do

    it "should allow you to add a new user entry" do 
      pending
    end

    it "should allow you to update a user entry" do 
      pending
    end

    it "should allow you to delete a user entry" do 
      pending
    end

  end


  describe "git proxy methods" do
    
    it "should allow you to change the global git user credentials" do
      pending
    end
    
    it "should allow you to change a specific repository's user credentials" do 
      pending
    end    
  end

end