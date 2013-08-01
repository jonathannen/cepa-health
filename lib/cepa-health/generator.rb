require 'rails/generators'
require 'securerandom'

module CepaHealth

  class InitializerGenerator < Rails::Generators::Base

    def create_initializer_file
      key = SecureRandom.hex(3)
      create_file "config/initializers/cepa_health.rb", <<-CONTENT
# Configure Cepa Health checks.
# See: https://github.com/cepaorg/cepa-health

# # Comment out the following to remove the standard probes.
CepaHealth.load_probes 

# # Comment out the below if you'd like your health check protected
# # by a key. The new health link will now be whatever the key is. In this 
# # example, "/healthcheck?key=#{key}"
# CepaHealth.key = "#{key}"

# # Add the following to bring a standard probe back after removing the above.
# CepaHealth.load_probe(:rails)

# # And/Or you can also add your own probes
# CepaHealth.register "Probe Name" do
#   record("Other result", true, "This will add another reporting row")
#   true # Ultimate result
# end
CONTENT
    end

  end

end
