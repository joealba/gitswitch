#require 'optparse'
require 'thor'


class GitSwitch
  class CLI < Thor

#  desc "switch [TAG]", ""
  
  desc "list", "Show all the git user tags you have configured"
  def list
    puts GitSwitch.list_users
  end
  
  # def self.run args = ARGV
  #   gitswitch = GitSwitch.new
  #   gitswitch.parse_args args
  # end





  # Read and parse the supplied command line arguments.
  # def parse_args args = ARGV
  #   args = ["-h"] if args.empty?
  # 
  #   parser = OptionParser.new do |o|
  #     o.banner = "Usage: gitswitch [options]"
  # 
  #     o.on "-l", "--list", "Show all git users you have configured" do
  #       list_users
  #       exit
  #     end
  # 
  #     o.on "-i", "--info", "Show the current git user info." do
  #       print_info
  #       exit
  #     end
  # 
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
  #     o.on "-h", "--help", "Show this help message." do
  #       print_info
  #       puts parser
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
  # 
  #     o.on("-v", "--version", "Show the current version.") do
  #       puts "GitSwitch " + GitSwitch::VERSION.to_s
  #       exit
  #     end      
  #   end
  #   
  #   begin
  #     parser.parse! args
  #   rescue OptionParser::InvalidOption => error
  #     puts error.message.capitalize
  #   rescue OptionParser::MissingArgument => error
  #     puts error.message.capitalize
  #   end
  # end


  
  end
end