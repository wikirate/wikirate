DelayedJobWeb.use Rack::Auth::Basic do |email, password|
  (account = Card::Auth.authenticate(email, password)) &&
    Card::Auth.admin?(account.left_id)
end
