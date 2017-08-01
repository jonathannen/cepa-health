# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "rspec/rails"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
