# note: in cap deployments, the current/config is symlinked to
# shared/config.  So long as that is the case, any changes here will need
# to be copied over manually to shared/config.

require "delayed_job_web"

DelayedJobWeb.use Rack::Auth::Basic do |email, password|
  account = Card::Auth.authenticate email, password
  Card::Auth.admin? account&.left_id
end
