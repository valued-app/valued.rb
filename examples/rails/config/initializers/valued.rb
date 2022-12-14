# frozen_string_literal: true
require "valued/rails"

Valued::Rails.setup do
  # Set up the Valued connection for the prodcution environment.
  # You can remove the condition if you want to use Valued in all environments.
  # Note that Valued will still be disabled if you don't set at least one of #token, #client, or #backend.
  connection :production do
    # Tell valued-rails where to find your Valued API token.
    # Accepts multiple values, which are tried in order.
    #
    # You can pass it as a string:
    #   token "my-token"
    #
    # You can pass a block:
    #   token { ENV["VALUED_TOKEN"] }
    #
    # Or you can pass one or more symbols:
    #   token :env
    #
    # With the following meaning:
    #   :env         - The VALUED_TOKEN environment variable
    #   :config      - From the environment section in the config/valued.yml file
    #   :credentials - From the valued section in the config/credentials.yml.enc or config/credentials/[env].yml.enc file
    token :env, :credentials, :config

    # Configure the Valued API endpoint.
    #
    # You can pass it as a string or URI:
    #   endpoint "https://custom-valued.enterprise.com/events"
    #
    # You can pass a block:
    #   endpoint { ENV["VALUED_ENDPOINT"] }
    #
    # Or you can pass one or more symbols:
    #   endpoint :env
    #
    # With the following meaning:
    #   :env         - The VALUED_ENDPOINT environment variable
    #   :config      - From the environment section in the config/valued.yml file
    #   :credentials - From the valued section in the config/credentials.yml.enc or config/credentials/[env].yml.enc file
    #   :default     - The default Valued endpoint
    endpoint :env, :credentials, :config, :default
  end

end