# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

if defined?(Rails)

  # A Trivial Rails probe.
  CepaHealth.register do
    ["Rails Major Version", true, Rails::VERSION::MAJOR]
  end

end
