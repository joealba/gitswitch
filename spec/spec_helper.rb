$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'gitswitch'
require 'rspec'
#require 'spec'
#require 'spec/autorun'

RSpec.configure do |c|
  # c.include Construct::Helpers
  # 
  # c.before do
  #   @user_dir = create_construct
  #   ENV['HOME'] = @user_dir.to_s
  # end
  # 
  # c.after do
  #   @user_dir.destroy!
  # end
end
