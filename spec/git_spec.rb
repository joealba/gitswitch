require 'spec_helper'

describe Gitswitch::Git do
  it "should find the git executable" do
    result = %x[#{Gitswitch::Git::GIT_BIN} --version]
    $?.exitstatus.should == 0
  end    

  it "should grab the local git version" do
    Gitswitch::Git.version.should =~ /^\d+\.+\d+/ # Should start off looking like a version number
  end

end