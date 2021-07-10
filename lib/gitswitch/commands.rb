require 'yaml'

module Gitswitch
  def self.gitswitch_config_file
    ENV['GITSWITCH_CONFIG_FILE'] || File.join(ENV["HOME"], ".gitswitch")
  end

  ##############################################################
  def self.users
    @users ||= load_users
  end

  def self.load_users
    user_hash = {}
    if Gitswitch::gitswitch_file_exists
      user_hash = YAML::load_file gitswitch_config_file
    end
    user_hash
  end

  ## Create a .gitswitch file with the current user defaults
  def self.create_fresh_gitswitch_file
    save_gitswitch_file({})
  end

  def self.gitswitch_file_exists
    File.exists? gitswitch_config_file
  end

  def self.save_gitswitch_file(users_hash)
    begin
      File.open(gitswitch_config_file, 'w') do |fh|
        fh.write(users_hash.to_yaml)
      end
    rescue
      warn "ERROR: Could not open/write the gitswitch config file: #{gitswitch_config_file}: #{$!}"
      exit
    end
    @users = nil
  end


  ##############################################################
  # Set git user parameters for a tag
  # ==== Parameters
  # * +tag+ - Required. The tag you want to add to your .gitswitch file
  # * +email+ - Required
  # * +name+ - Required
  def self.set_gitswitch_entry(tag, email, name)
    users[tag] = {name: name, email: email}
    save_gitswitch_file(users)
  end

  def self.delete_gitswitch_entry(tag)
    if tag == 'default'
      puts "Cannot delete the default tag.  Use the update command instead"
      exit
    end
    users.delete(tag)
    save_gitswitch_file(users)
  end

  def self.get_user(tag)
    ## TODO: Stop coding so defensively.
    if !users.empty? && users[tag] && !users[tag].empty?
      users[tag]
    end
  end

  def self.get_tags
    users.keys
  end

  def self.get_tag_display
    users.map do |key, user|
      item = "#{key}:\n"
      item << "  Name:   #{user[:name]}\n" if !user[:name].to_s.empty?
      item << "  E-mail: #{user[:email]}\n"
      item
    end.join("\n")
  end

  def self.list_users
    response = "\nCurrent git user options --\n"
    response << get_tag_display

    response
  end

  ## Return active user information.
  ## If you're in a git repo, show that user info.  Otherwise, display the global info.
  def self.current_user_info(options = {})
    current_git_user = Gitswitch::get_git_user_info(options)

    response = !Gitswitch::in_a_git_repo || options[:global] ? "Your git user information from your global config:\n" : "Your git user information from the current repository:\n"
    response << "Name:   #{current_git_user[:name]}\n"
    response << "E-mail: #{current_git_user[:email]}\n"

    response
  end


  ##############################################################
  # Switch git user in your global .gitconfig file
  # ==== Parameters
  # * +tag+ - The tag associated with your desired git info in .gitswitch.  Defaults to "default".
  def self.switch_global_user(tag = "default")
    if user = get_user(tag)
      puts "Switching your .gitconfig user info to \"#{tag}\" tag (#{user[:name]} <#{user[:email]}>)."
      git_config(user, {global: true})
    else
      puts "ERROR: Could not find info for tag \"#{tag}\" in your .gitswitch file"
    end
  end


  ##############################################################
  # Set the git user information for current repository
  # ==== Parameters
  # * +tag+ - The tag associated with your desired git info in .gitswitch. Defaults to "default".
  def self.switch_repo_user(tag = "default")
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

  ##############################################################
  # TODO: Straight delegation through to Gitswitch::Git
  def self.in_a_git_repo
    Gitswitch::Git.in_a_git_repo
  end

  def self.git_config(user, options = {})
    Gitswitch::Git.git_config(user, options)
  end

  def self.get_git_user_info(options = {})
    Gitswitch::Git.get_git_user_info(options)
  end
end
