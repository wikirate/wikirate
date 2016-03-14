view :raw do |_args|
  File.read File.expand_path('../../lib/javascript/metrics.js.coffee', __FILE__)
end