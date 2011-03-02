require 'yaml'
require 'shellwords' if !String.new.methods.include?('shellescape')


class Gitswitch
  GITSWITCH_CONFIG_FILE = File.join ENV["HOME"], ".gitswitch"
  GIT_BIN = '/usr/bin/env git'

  attr_reader :users


  ##############################################################
  def initialize
    @users = {}
    if Gitswitch::gitswitch_file_exists
      @users = YAML::load_file GITSWITCH_CONFIG_FILE
      if @users.nil?
        puts "Error loading .gitswitch file.  Delete the file and start fresh." 
        exit
      end
    end
  end
    

  ##############################################################
  # Create a .gitswitch file with the current user defaults
  def create_fresh_gitswitch_file
    @users = {}
    save_gitswitch_file
  end

  def self.gitswitch_file_exists
    File.exists? GITSWITCH_CONFIG_FILE
  end

  def save_gitswitch_file
    if fh = File.open(GITSWITCH_CONFIG_FILE, 'w')
      fh.write(@users.to_yaml)
      fh.close
    else
      puts "ERROR: Could not open/write the gitswitch config file: #{GITSWITCH_CONFIG_FILE}"
    end
  end


  ##############################################################
  # Set git user parameters for a tag
  # ==== Parameters
  # * +tag+ - Required. The tag you want to add to your .gitswitch file
  # * +email+ - Required
  # * +name+ - Required
  def set_gitswitch_entry(tag, email, name)
    @users[tag] = {:name => name, :email => email}
    save_gitswitch_file
  end

  def delete_gitswitch_entry(tag)
    if tag == 'default'
      puts "Cannot delete the default tag.  Use the update command instead"
      exit
    end
    @users.delete(tag)
    save_gitswitch_file
  end

  def get_user(tag)     
    if !@users.empty? && @users[tag] && !@users[tag].empty?
      @users[tag]
    end
  end

  def get_tags
    @users.keys
  end

  def get_tag_display
    max_length = @users.keys.sort{|x,y| y.length <=> x.length }.first.length
    @users.each_pair.map {|key,value| sprintf("  %#{max_length}s  %s\n", key, value[:email]) }
  end

  def list_users
    response = ''
    response << "\nCurrent git user options --\n"
    @users.each do |key, user|
      response << "#{key}:\n"
      response << "  Name:   #{user[:name]}\n" if !user[:name].to_s.empty?
      response << "  E-mail: #{user[:email]}\n\n"
    end
    response
  end

  ## Return active user information.
  ## If you're in a git repo, show that user info.  Otherwise, display the global info.
  def self.current_user_info(options = {})
    response = !Gitswitch::in_a_git_repo || options[:global] ? "Your git user information from your global config:\n" : "Your git user information from the current repository:\n"
    current_git_user = Gitswitch::get_git_user_info(options)
    response << "Name:   #{current_git_user[:name]}\n" 
    response << "E-mail: #{current_git_user[:email]}\n"
    response
  end

  def self.in_a_git_repo
    %x(#{GIT_BIN} status 2>&1 | head -n 1).to_s =~ /^fatal/i ? false : true
  end


  ##############################################################
  def git_config(user, options = {})
    git_args = 'config --replace-all'
    git_args += ' --global' if options[:global]
  
    %x(#{GIT_BIN} #{git_args} user.email #{user[:email].to_s.shellescape})
    %x(#{GIT_BIN} #{git_args} user.name #{user[:name].to_s.shellescape}) if !user[:name].to_s.empty?
  end


  ##############################################################
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
    if !Gitswitch::in_a_git_repo
      puts "You do not appear to currently be in a git repository directory"
      false
    else
      if user = get_user(tag)
        puts "Switching git user to \"#{tag}\" tag for the current repository (#{user[:name]} <#{user[:email]}>)."
        git_config(user) or raise "Could not change the git user settings to your repository."
      else
        puts "ERROR: Could not find info for tag \"#{tag}\" in your .gitswitch file"
      end
    end
  end


  
  private

  # Show the current git user info
  def self.get_git_user_info(options = {})
    git_args = 'config --get'
    git_args += ' --global' if options[:global]
  
    {
      :name => %x(#{GIT_BIN} #{git_args} user.name).to_s.chomp,
      :email => %x(#{GIT_BIN} #{git_args} user.email).to_s.chomp
    } 
  end

end
