ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
class Minitest::Unit::TestCase
  include FactoryGirl::Syntax::Methods
end
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end
