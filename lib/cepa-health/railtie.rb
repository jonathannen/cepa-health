# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

module CepaHealth

  class Railtie < Rails::Railtie

    initializer "cepa_health.configure_rails_initialization" do |app|
      app.middleware.use CepaHealth::Middleware
    end

  end

end
