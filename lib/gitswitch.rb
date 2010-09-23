require 'optparse'
require 'yaml'
require 'shellwords' if !String.new.methods.include?('shellescape')


class GitSwitch
  GITSWITCH_CONFIG_FILE = File.join ENV["HOME"], ".gitswitch"
  GIT_BIN = '/usr/bin/env git'
  VERSION_FILE = File.join File.dirname(__FILE__), "..", "VERSION"
  

  def self.run args = ARGV
    gitswitch = GitSwitch.new
    gitswitch.parse_args args
  end


  def initialize
    @users = {}
    if File.exists? GITSWITCH_CONFIG_FILE
      @users = YAML::load_file GITSWITCH_CONFIG_FILE
      if @users.nil?
        puts "Error loading .gitswitch file" 
        exit
      end
    else
      print "Gitswitch users file ~/.gitswitch not found.  Would you like to create one? (y/n): "
      if gets.chomp =~ /^y/i
        create_gitswitch_file
      else
        puts "Ok, that's fine.  Exiting."
        exit
      end
    end
  end


  # Read and parse the supplied command line arguments.
  def parse_args args = ARGV
    args = ["-h"] if args.empty?

    parser = OptionParser.new do |o|
      o.banner = "Usage: gitswitch [options]"

      o.on "-l", "--list", "Show all git users you have configured" do
        list_users
        exit
      end

      o.on "-i", "--info", "Show the current git user info." do
        print_info
        exit
      end

      o.on "-s", "--switch [TAG]", String, "Switch git user to the specified tag in your user's global git configuration" do |tag|
        tag ||= 'default'
        switch_global_user(tag)
        print_info
        exit
      end

      o.on "-r", "--repo [TAG]", String, "Switch git user to the specified tag for the current directory's git repository" do |tag|
        tag ||= 'default'
        switch_repo_user(tag)
        exit
      end

      o.on "-h", "--help", "Show this help message." do
        print_info
        puts parser
        exit
      end

      o.on "-o", "--overwrite", "Overwrite/create a .gitswitch file using your global git user info as default" do
        create_gitswitch_file
        print_info
        exit
      end

      o.on "-a", "--add [TAG]", "Add a new gitswitch entry" do |tag|
        add_gitswitch_entry(tag)
        exit
      end

      o.on("-v", "--version", "Show the current version.") do
        print_version
        exit
      end      
    end
    
    begin
      parser.parse! args
    rescue OptionParser::InvalidOption => error
      puts error.message.capitalize
    rescue OptionParser::MissingArgument => error
      puts error.message.capitalize
    end
  end
  


  # Create a .gitswitch file with the current user defaults
  def create_gitswitch_file
    user = get_git_user_info({:global => true})
    if user[:name].empty? && user[:email].empty?
      puts "ERROR: You must set up a default git user.name and user.email first."
    else
      puts "Adding your global .gitconfig user info to the \"default\" tag..."
      set_gitswitch_entry('default', user[:email], user[:name])
      save_gitswitch_file
    end
  end


  def save_gitswitch_file
    if fh = File.open(GITSWITCH_CONFIG_FILE, 'w')
      fh.write(@users.to_yaml)
      fh.close
    else
      puts "ERROR: Could not open/write the gitswitch config file: #{GITSWITCH_CONFIG_FILE}"
    end
  end


  # Set git user parameters for a tag
  # ==== Parameters
  # * +tag+ - Required. The tag you want to add to your .gitswitch file
  # * +email+ - Required
  # * +name+ - Required
  def set_gitswitch_entry(tag, email, name)
    @users[tag] = {:name => name, :email => email}
    save_gitswitch_file
  end


  def get_user(tag)     
    if !@users.empty? && @users[tag] && !@users[tag].empty?
      @users[tag]
    end
  end


  def git_config(user, args = {})
    git_args = 'config --replace-all'
    git_args += ' --global' if args[:global]
    
    %x(#{GIT_BIN} #{git_args} user.email #{user[:email].to_s.shellescape})
    %x(#{GIT_BIN} #{git_args} user.name #{user[:name].to_s.shellescape}) if !user[:name].to_s.empty?
  end

  
  # Switch git user in your global .gitconfig file
  # ==== Parameters
  # * +tag+ - The tag associated with your desired git info in .gitswitch.  Defaults to "default".
  def switch_global_user tag = "default"
    if user = get_user(tag)
      puts "Switching your .gitconfig user info to \"#{tag}\" tag (#{user[:name]} <#{user[:email]}>)."
      git_config(user, {:global => true})
    else
      puts "ERROR: Could not find info for tag \"#{tag}\" in your .gitswitch file"
    end
  end


  # Set the git user information for current repository
  # ==== Parameters
  # * +tag+ - The tag associated with your desired git info in .gitswitch. Defaults to "default".
  def switch_repo_user(tag = "default")
    ## TODO: See if we're actually in a git repo
    if user = get_user(tag)
      puts "Switching git user to \"#{tag}\" tag for the current repository (#{user[:name]} <#{user[:email]}>)."
      git_config(user) or raise "Could not change the git user settings to your repository."
    else
      puts "ERROR: Could not find info for tag \"#{tag}\" in your .gitswitch file"
    end
  end
  
  
  # Add a user entry to your .gitswitch file
  def add_gitswitch_entry(tag = '')
    if (!tag.nil? && !tag.empty?)
      tag.gsub!(/\W+/,'')
    else
      print "Enter a tag to describe this git user entry: "
      tag = gets.gsub(/\W+/,'')
    end
    
    if tag.empty?
      puts "You must enter a short tag to describe the git user entry you would like to save."
      exit
    end

    puts "Adding a new gitswitch user entry for tag '#{tag}'"
    print "  E-mail address: "
    email = gets.chomp

    print "  Name: (ENTER to use \"" + get_git_user_info({:global => true})[:name] + "\") "
    name = gets.chomp
    name = get_git_user_info({:global => true})[:name] if name.empty?

    set_gitswitch_entry(tag, email, name)
  end
  
  
  def list_users
    puts "\nCurrent git user options --"
    @users.each do |key, user|
      puts "#{key}:"
      puts "  Name:   #{user[:name]}" if !user[:name].to_s.empty?
      puts "  E-mail: #{user[:email]}\n"
    end
  end

  
  # Print active account information.
  def print_info
    current_git_user = get_git_user_info
    puts "Current git user information:\n"
    puts "Name:   #{current_git_user[:name]}" 
    puts "E-mail: #{current_git_user[:email]}"
    puts
  end

  
  # Print version information.
  def print_version
    if fh = File.open(VERSION_FILE,'r')
      puts "GitSwitch " + fh.gets
      fh.close
    else
      puts "Version information not found"
    end    
    #    puts "GitSwitch " + GitSwitch::VERSION.to_s
  end

  
  private

  # Show the current git user info
  def get_git_user_info(args = {})
    git_args = 'config --get'
    git_args += ' --global' if args[:global]
    
    {
      :name => %x(#{GIT_BIN} #{git_args} user.name).to_s.chomp,
      :email => %x(#{GIT_BIN} #{git_args} user.email).to_s.chomp
    } 
  end
  
end
