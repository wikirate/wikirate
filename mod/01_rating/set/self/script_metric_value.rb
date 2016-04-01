view :raw do |_args|
  File.read "#{Rails.root}/mod/01_rating/lib/javascript/metric_value.js.coffee"
end

format(:html) { include ScriptAce::HtmlFormat }
