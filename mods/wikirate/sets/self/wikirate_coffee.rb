# -*- encoding : utf-8 -*-
=begin
view :raw do |args|
  File.read "#{Wagn.root}/mods/wikirate/lib/javascripts/wikirate_coffee.coffee"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
=end

event :compile_to_cached_card, :after=>:store, :on=>:save do
  Card[:wikirate_javascript].update_attributes! :content=> Card::JsFormat.new(self)._render_core
end
  