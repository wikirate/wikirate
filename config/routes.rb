# -*- encoding : utf-8 -*-

require 'decko/engine'
require 'delayed_job_web'

Rails.application.routes.draw do
 mount DelayedJobWeb => "/*admin/delayed_job"
 mount Decko::Engine => '/'
end
