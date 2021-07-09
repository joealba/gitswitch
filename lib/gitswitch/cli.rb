require "dry/cli"
require "tty-prompt"

module Gitswitch
  module CLI
    module Helpers
      def prompt_for_email_and_name
        prompt = TTY::Prompt.new
        email = prompt.ask("  E-mail address: ").to_s.chomp
        if email.empty?
          puts "No e-mail address provided"
          exit Gitswitch::EXIT_MISSING_INFO
        end

        default_name = Gitswitch::get_git_user_info({global: true})[:name]
        name = prompt.ask("  Name: (ENTER to use \"" + default_name + "\") ").to_s.chomp
        name = default_name if name.empty?

        if name.empty?
          puts "No name provided"
        end

        return [email, name]
      end
    end

    module Commands
      extend Dry::CLI::Registry

      class Init < Dry::CLI::Command
        desc "Initialize your .gitswitch file"

        def call(*)
          prompt = TTY::Prompt.new

          if !Gitswitch::gitswitch_file_exists
            if prompt.yes?("Gitswitch users file ~/.gitswitch not found.  Would you like to create one? (y/n):")
              Gitswitch.create_fresh_gitswitch_file
            else
              puts "Ok, that's fine.  Exiting."
              exit Gitswitch::EXIT_OK
            end
          else
            if prompt.yes?("Gitswitch users file ~/.gitswitch already exists.  Would you like to wipe it out and create a fresh one? (y/n):")
              Gitswitch.create_fresh_gitswitch_file
            end
          end

          # Grab the current global info to drop into the default slot -- if available
          user = Gitswitch.get_git_user_info({global: true})
          if user[:name].empty? && user[:email].empty?
            puts "No global git user.name and user.email configurations were found.  Set up a default now."
            add('default')
          else
            puts "Adding your global .gitconfig user info to the \"default\" tag..."
            Gitswitch.set_gitswitch_entry('default', user[:email], user[:name])
          end

          exit Gitswitch::EXIT_OK
        end
      end

      class Info < Dry::CLI::Command
        desc "Show the current git user"
        option :global, type: :boolean, default: false, desc: "Show global config"

        def call(**options)
          puts Gitswitch.current_user_info(options)

          exit Gitswitch::EXIT_OK
        end
      end

      class List < Dry::CLI::Command
        desc "Show all the git user tags you have configured"

        def call(*)
          puts Gitswitch.list_users

          exit Gitswitch::EXIT_OK
        end
      end

      class Switch < Dry::CLI::Command
        desc "Switch git user"
        argument :tag, desc: "Tag name"
        option :global, type: :boolean, default: false, desc: "Set global config"

        def call(tag: "default", **options)
          options[:global] ? Gitswitch.switch_global_user(tag) : Gitswitch.switch_repo_user(tag)
          puts Gitswitch.current_user_info(options)

          exit Gitswitch::EXIT_OK
        end
      end

      class Global < Dry::CLI::Command
        desc "Switch the global git user info (your ~/.gitconfig file)"
        argument :tag, desc: "Tag name"

        def call(tag: "default", **)
          Gitswitch.switch_global_user(tag)

          exit Gitswitch::EXIT_OK
        end
      end

      class Add < Dry::CLI::Command
        include ::Gitswitch::CLI::Helpers

        desc "Add a new tagged user entry"
        argument :tag, desc: "Tag name"

        def call(tag: "", **)
          tag = tag.gsub(/\W+/,'')
          if (tag.nil? || tag.empty?)
            prompt = TTY::Prompt.new
            tag = prompt.ask("Enter a tag to describe this git user entry: ").to_s.gsub(/\W+/,'')
          end

          if tag.empty?
            puts "You must enter a short tag to describe the git user entry you would like to save."
            exit Gitswitch::EXIT_MISSING_INFO
          end

          puts "Adding a new gitswitch user entry for tag '#{tag}'"
          (email, name) = prompt_for_email_and_name
          Gitswitch.set_gitswitch_entry(tag, email, name)
          exit Gitswitch::EXIT_OK
        end
      end

      class Delete < Dry::CLI::Command
        desc "Delete a tagged user entry"

        def call(tag: "")
          tag_table = Gitswitch.get_tag_display

          tag = tag.gsub(/\W+/, '')
          if (tag.empty?)
            puts tag_table
            prompt = TTY::Prompt.new
            tag = prompt.ask("\nWhich tag would you like to delete: ").to_s.gsub(/\W+/,'')
          end

          if tag.empty?
            puts "No tag chosen"
            exit Gitswitch::EXIT_MISSING_INFO
          end

          Gitswitch.delete_gitswitch_entry(tag)

          puts Gitswitch.get_tag_display

          exit Gitswitch::EXIT_OK
        end
      end

      class Update < Dry::CLI::Command
        include ::Gitswitch::CLI::Helpers

        desc "Update a tagged user entry"
        argument :tag, desc: "Tag name"

        def call(tag: "", **)
          tag_table = Gitswitch.get_tag_display

          tag = tag.gsub(/\W+/, '')
          if (tag.empty?)
            prompt = TTY::Prompt.new
            tag = prompt.ask("Which tag would you like to update: \n#{tag_table}\nTag: ").to_s.gsub(/\W+/,'')
          end

          if tag.empty?
            puts "No tag chosen"
            exit Gitswitch::EXIT_MISSING_INFO
          end

          puts "Updating #{tag} entry..."
          (email, name) = prompt_for_email_and_name
          Gitswitch.set_gitswitch_entry(tag, email, name)

          exit Gitswitch::EXIT_OK
        end
      end

      class Version < Dry::CLI::Command
        desc "Show the gitswitch version"

        def call(*)
          puts Gitswitch::VERSION

          exit Gitswitch::EXIT_OK
        end
      end

      register "add", Add, aliases: ["-a", "--add"]
      register "delete", Delete, aliases: ["remove"]
      register "info", Info, aliases: ["-i", "--info"]
      register "init", Init
      register "list", List, aliases: ["-l", "--list"]
      register "switch", Switch, aliases: ["-r"]
      register "update", Update, aliases: ["-o","--overwrite"]
      register "version", Version, aliases: ["-v", "--version"]
    end
  end
end
