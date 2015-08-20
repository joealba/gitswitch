require 'spec_helper'

describe Gitswitch do

  describe "basics" do
    it "should have a VERSION" do
      expect(Gitswitch::VERSION).not_to eq ''
    end
  end

  describe "read-only" do
    it "shows the current list of available gitswitch tags" do
      skip
    end
  end

  describe "write methods" do
    before :each do
      Gitswitch.create_fresh_gitswitch_file
    end

    it "allows you to add a new user entry" do
      initial_user_count = Gitswitch.users.keys.count
      set_test_entry
      expect(Gitswitch.users.keys.count > initial_user_count).to eq true
    end

    it "allows you to update a user entry" do
      set_test_entry
      test_entry = get_test_entry
      Gitswitch.set_gitswitch_entry(test_entry[0], 'testing@test.com', test_entry[2])
      expect(Gitswitch.get_user(test_entry[0])[:email]).to eq 'testing@test.com'
      expect(Gitswitch.get_user(test_entry[0])[:name]).to eq test_entry[2]
    end

    it "allows you to delete a user entry" do
      set_test_entry
      Gitswitch.delete_gitswitch_entry(get_test_entry[0])
      expect(Gitswitch.users.keys.count).to eq 0
    end

    it "allows you to overwrite the current .gitswitch file and start fresh" do
      set_test_entry
      Gitswitch.create_fresh_gitswitch_file
      expect(Gitswitch.users.keys.count).to eq 0
    end

  end


  describe "weird outlier cases" do
    it "in a git repo directory with no user info specified, show the global config header and user info" do
      skip
    end
  end


  it "shows the current git user credentials" do
    expect(Gitswitch.current_user_info).to match /^Your git user/
  end


end
