require 'spec_helper'

describe Gitswitch::Git do
  it "finds the git executable" do
    result = %x[#{Gitswitch::Git::GIT_BIN} --version]
    expect($?.exitstatus).to eq 0
  end

  it "grabs the local git version" do
    expect(Gitswitch::Git.version).to match /^\d+\.+\d+/ # Should start off looking like a version number
  end

end