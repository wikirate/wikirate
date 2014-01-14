# This file is used by Rack-based servers to start the application.

require 'wagn/environment'

# to test non-root in webrick, uncomment the map call and use this command:
# > env RAILS_RELATIVE_URL_ROOT='/root' rails server 
# note: above needs to be tested and updated for wagn as gem

# map '/root' do
  run Wagn::Application
# end