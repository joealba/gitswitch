$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'gitswitch'

require 'bundler'
Bundler.setup


RSpec.configure do |c|
end

ENV['GITSWITCH_CONFIG_FILE'] = File.join(File.dirname(__FILE__), 'tmp', '.gitswitch')

def get_test_entry
  ['test','test@null.com', 'A. Tester']
end

def set_test_entry
  Gitswitch.set_gitswitch_entry(*get_test_entry)
end