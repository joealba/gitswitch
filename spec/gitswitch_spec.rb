require 'spec_helper'

describe Gitswitch do

  describe "basics" do
    it "should have a VERSION" do
      Gitswitch::VERSION.should_not == ''
    end
  end

  describe "read-only" do
    it "should show the current list of available gitswitch tags" do
          
    end
  end

  describe "write methods" do
    before :each do 
      Gitswitch.create_fresh_gitswitch_file 
    end

    it "should allow you to add a new user entry" do
      initial_user_count = Gitswitch.users.keys.count
      set_test_entry
      Gitswitch.users.keys.count.should be > initial_user_count
    end

    it "should allow you to update a user entry" do 
      set_test_entry
      test_entry = get_test_entry
      Gitswitch.set_gitswitch_entry(test_entry[0], 'testing@test.com', test_entry[2])
      Gitswitch.get_user(test_entry[0])[:email].should eq('testing@test.com')
      Gitswitch.get_user(test_entry[0])[:name].should eq(test_entry[2])
    end

    it "should allow you to delete a user entry" do 
      set_test_entry
      Gitswitch.delete_gitswitch_entry(get_test_entry[0])
      Gitswitch.users.keys.count.should == 0
    end

    it "should allow you to overwrite the current .gitswitch file and start fresh" do
      set_test_entry
      Gitswitch.create_fresh_gitswitch_file 
      Gitswitch.users.keys.count.should == 0
    end

  end


  describe "weird outlier cases" do
    it "in a git repo directory with no user info specified, show the global config header and user info" do
      pending
    end
  end


  it "should show the current git user credentials" do
    Gitswitch.current_user_info.should =~ /^Your git user/
  end


end
