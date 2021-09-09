# -*- encoding : utf-8 -*-

require 'decko/engine'
require 'delayed_job_web'

Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  options "/graphql", to: "graphql#execute"

  # if Rails.env.development?
  #   mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  # end
  mount DelayedJobWeb => "/*admin/delayed_job"
  mount Decko::Engine => '/'
end
