# note: in cap deployments, the shared/config/initializers directory links to this file's
# "initializers" directory

# better still would be to move this to a mod.

require "delayed_job_web"

DelayedJobWeb.use Rack::Auth::Basic do |email, password|
  account = Card::Auth.authenticate email, password
  Card::Auth.admin? account&.left_id
end
