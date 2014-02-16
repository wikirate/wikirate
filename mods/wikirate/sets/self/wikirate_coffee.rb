# -*- encoding : utf-8 -*-
view :raw do |args|
  File.read "#{Wagn.root}/mods/wikirate/lib/javascripts/wikirate_coffee.coffee"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
