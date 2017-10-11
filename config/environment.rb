# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Wikirate::Application.initialize!
Wikirate::Application.config.import_sources = true
