require 'spec_helper'

describe GitSwitch do
  # before do
  #   @homesick = Homesick.new
  # end
    
  describe "version" do
    it "should have a VERSION" do
      VERSION.should_not == ''
    end
  end

  describe "basics" do
    it "should find the git executable" do
      result = %x[#{GitSwitch::GIT_BIN} --version]
      $?.exitstatus.should == 0
    end
    
  end

end