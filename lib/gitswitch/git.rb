require 'shellwords' if !String.new.methods.include?('shellescape')

module Gitswitch
  module Git
    GIT_BIN = '/usr/bin/env git'

    def self.version
      %x(#{GIT_BIN} --version).to_s.gsub(/^git version\s*/, '')
    end

    def self.in_a_git_repo
      %x(#{GIT_BIN} status 2>&1 | head -n 1).to_s =~ /^fatal/i ? false : true
    end

    def self.git_config(user, options = {})
      git_args = 'config --replace-all'
      git_args += ' --global' if options[:global]

      %x(#{GIT_BIN} #{git_args} user.email #{user[:email].to_s.shellescape})
      %x(#{GIT_BIN} #{git_args} user.name #{user[:name].to_s.shellescape}) if !user[:name].to_s.empty?
    end

    def self.get_git_user_info(options = {})
      git_args = 'config --get'
      git_args += ' --global' if options[:global]

      {
        name: %x(#{GIT_BIN} #{git_args} user.name).to_s.chomp,
        email: %x(#{GIT_BIN} #{git_args} user.email).to_s.chomp
      }
    end
  end
end
