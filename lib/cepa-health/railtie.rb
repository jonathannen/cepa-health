# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

module CepaHealth

  class Railtie < Rails::Railtie

    initializer "cepa_health.configure_rails_initialization" do |app|
      # Try and insert high up the chain. This means the health check
      # will generally run before sessions are created, etc. This is 
      # particularly handy if you have Database-backed sessions.
      begin
        app.middleware.insert_before Rack::Runtime, CepaHealth::Middleware
      rescue
        app.middleware.use CepaHealth::Middleware
      end
    end

  end

end
