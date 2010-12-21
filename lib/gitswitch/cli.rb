#require 'optparse'
require 'thor'


class GitSwitch
  class CLI < Thor

  
  ######################################################################
  desc "list", "Show all the git user tags you have configured"
  map ["-l","--list"] => :list
  def list
    puts GitSwitch.new.list_users
  end


  ######################################################################
  desc "info", "Show the current git user"
  map "-i" => :info
  def info
    puts GitSwitch.current_user_info
  end


  ######################################################################
  desc "version", "Show the gitswitch version"
  map ["-v","--version"] => :version
  def version
    puts GitSwitch.VERSION
  end


  ######################################################################
  desc "switch [TAG]", "Switch git user"
  map "-r" => :switch
  method_option :global, :type => :boolean, :aliases => ["-s","--global"] ## To support the deprecated behavior
  method_option :repository, :type => :boolean, :aliases => "-r"
  def switch(tag = 'default')
    options[:global] ? switch_global(tag) : GitSwitch.new.switch_repo_user(tag)
    puts GitSwitch.current_user_info
  end


  ######################################################################
  desc "global [TAG]", "Switch global git user"
  map "-s" => :switch_global
  def switch_global(tag = 'default')
    GitSwitch.new.switch_global_user(tag)
    puts GitSwitch.current_user_info
  end


  ######################################################################
  desc "add [TAG]", "Add a new tagged user entry"
  map ["-a","--add"] => :add
  def add(tag = 'default')
    tag.gsub!(/\W+/,'')
    tag = ask("Enter a tag to describe this git user entry: ").gsub(/\W+/,'') if (tag.nil? || tag.empty?)
  
    if tag.empty?
      puts "You must enter a short tag to describe the git user entry you would like to save."
      exit
    end

    gs = GitSwitch.new

    puts "Adding a new gitswitch user entry for tag '#{tag}'"
    email = ask("  E-mail address: ").chomp
    name = ask("  Name: (ENTER to use \"" + GitSwitch::get_git_user_info({:global => true})[:name] + "\") ").chomp
    name = GitSwitch::get_git_user_info({:global => true})[:name] if name.empty?

    gs.set_gitswitch_entry(tag, email, name)
  end




  ######################################################################
  ## Wow, this didn't work before.  Ugh.  
  desc "update [TAG]", "Update a tagged user entry"
  map ["-o","--overwrite"] => :add
  def update(tag = '')
    gs = GitSwitch.new

    tag_table = gs.get_tag_display
    
    tag.gsub!(/\W+/,'')
    if (tag.nil? || tag.empty?)
      tag = ask("Which tag would you like to update: \n#{tag_table}").gsub(/\W+/,'') 
    end

    GitSwitch.new.set_gitswitch_entry(tag, email, name)
  end


  ######################################################################
  desc "delete [TAG]", "Delete a tagged user entry"
  def delete(tag = '')
    gs = GitSwitch.new

    tag_table = gs.get_tag_display
    
    tag.gsub!(/\W+/,'')
    if (tag.nil? || tag.empty?)
      tag = ask("Which tag would you like to delete: \n#{tag_table}").gsub(/\W+/,'') 
    end

    GitSwitch.new.delete_gitswitch_entry(tag)
  end




  #     o.on "-s", "--switch [TAG]", String, "Switch git user to the specified tag in your user's global git configuration" do |tag|
  #       tag ||= 'default'
  #       switch_global_user(tag)
  #       print_info
  #       exit
  #     end
  # 
  #     o.on "-r", "--repo [TAG]", String, "Switch git user to the specified tag for the current directory's git repository" do |tag|
  #       tag ||= 'default'
  #       switch_repo_user(tag)
  #       exit
  #     end
  # 
  #     o.on "-o", "--overwrite", "Overwrite/create a .gitswitch file using your global git user info as default" do
  #       create_gitswitch_file
  #       print_info
  #       exit
  #     end
  # 
  #     o.on "-a", "--add [TAG]", "Add a new gitswitch entry" do |tag|
  #       add_gitswitch_entry(tag)
  #       exit
  #     end

  
  end
end