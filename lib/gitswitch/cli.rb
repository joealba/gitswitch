require 'thor'


class Gitswitch
  class CLI < Thor


    ######################################################################
    desc "init", "Initialize your .gitswitch file"
    def init
      if !Gitswitch::gitswitch_file_exists
        if yes?("Gitswitch users file ~/.gitswitch not found.  Would you like to create one? (y/n): ")
          Gitswitch::new.create_fresh_gitswitch_file
        else
          puts "Ok, that's fine.  Exiting."
          exit
        end
      else
        if yes?("Gitswitch users file ~/.gitswitch already exists.  Would you like to wipe it out and create a fresh one? (y/n): ")
          Gitswitch::new.create_fresh_gitswitch_file
        end
      end

      # Grab the current global info to drop into the default slot -- if available
      user = Gitswitch::get_git_user_info({:global => true})
      if user[:name].empty? && user[:email].empty?
        puts "No global git user.name and user.email configurations were found.  Set up a default now."
        add('default')
      else
        puts "Adding your global .gitconfig user info to the \"default\" tag..."
        Gitswitch::new.set_gitswitch_entry('default', user[:email], user[:name])
      end

    end

  
    ######################################################################
    desc "version", "Show the gitswitch version"
    map ["-v","--version"] => :version
    def version
      puts Gitswitch::VERSION
    end


    ######################################################################
    desc "info", "Show the current git user"
    map "-i" => :info
    method_option :global, :type => :boolean
    def info
      puts Gitswitch.current_user_info(options)
    end


    ######################################################################
    desc "list", "Show all the git user tags you have configured"
    map ["-l","--list"] => :list
    def list
      puts Gitswitch.new.list_users
    end


    ######################################################################
    desc "switch [TAG]", "Switch git user"
    map "-r" => :switch
    method_option :global, :type => :boolean, :aliases => ["-s","--global"] ## To support the deprecated behavior
    method_option :repository, :type => :boolean, :aliases => "-r"
    def switch(tag = 'default')
      options[:global] ? global(tag) : Gitswitch.new.switch_repo_user(tag)
      puts Gitswitch.current_user_info(options)
    end


    ######################################################################
    desc "global [TAG]", "Switch global git user (your ~/.gitconfig file)"
    map "-s" => :global
    def global(tag = 'default')
      Gitswitch.new.switch_global_user(tag)
    end


    ######################################################################
    desc "add [TAG]", "Add a new tagged user entry"
    map ["-a","--add"] => :add
    def add(tag = '')
      gs = Gitswitch.new

      tag.gsub!(/\W+/,'')
      tag = ask("Enter a tag to describe this git user entry: ").gsub(/\W+/,'') if (tag.nil? || tag.empty?)
  
      if tag.empty?
        puts "You must enter a short tag to describe the git user entry you would like to save."
        exit
      end

      puts "Adding a new gitswitch user entry for tag '#{tag}'"
      (email, name) = prompt_for_email_and_name
      gs.set_gitswitch_entry(tag, email, name)
    end


    ######################################################################
    desc "update [TAG]", "Update a tagged user entry"
    map ["-o","--overwrite"] => :add
    def update(tag = '')
      gs = Gitswitch.new
      tag_table = gs.get_tag_display
    
      tag.gsub!(/\W+/,'')
      if (tag.nil? || tag.empty?)
        tag = ask("Which tag would you like to update: \n#{tag_table}").gsub(/\W+/,'') 
      end
      
      puts "Updating #{tag} entry..."
      (email, name) = prompt_for_email_and_name
      Gitswitch.new.set_gitswitch_entry(tag, email, name)
    end


    ######################################################################
    desc "delete [TAG]", "Delete a tagged user entry"
    def delete(tag = '')
      gs = Gitswitch.new

      tag_table = gs.get_tag_display
    
      tag.gsub!(/\W+/,'')
      if (tag.nil? || tag.empty?)
        tag = ask("Which tag would you like to delete: \n#{tag_table}").gsub(/\W+/,'') 
      end

      Gitswitch.new.delete_gitswitch_entry(tag)
    end


    private
    

    ######################################################################
    def prompt_for_email_and_name 
      email = ask("  E-mail address: ").chomp
      ## TODO: Validate e-mail
      if email.nil?
        puts "No name provided"
        exit
      end
      
      name = ask("  Name: (ENTER to use \"" + Gitswitch::get_git_user_info({:global => true})[:name] + "\") ").chomp
      name = Gitswitch::get_git_user_info({:global => true})[:name] if name.empty?
      
      if name.nil?
        puts "No name provided"
        exit
      end

      return [email, name]
    end

  
  end
end