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

  describe "functionals" do
    it "should show the current git user credentials" do
      pending
      # result = GitSwitch.run
      # result.should =~ /^Current git user info/
    end

    it "should allow you to add a new user credential entry" do 
      pending
    end
    
    it "should allow you to change the global git user credentials" do
      pending
    end
    
    it "should allow you to change a specific repository's user credentials" do 
      pending
    end    
  end

end