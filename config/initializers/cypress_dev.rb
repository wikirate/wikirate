if defined?(CypressDev)
  CypressDev.configure do |c|
    c.cypress_folder = File.join Decko.gem_root, "spec/cypress"
    c.use_middleware = Rails.env.cypress?
    c.logger = Rails.logger
  end
end
