
view :paragraph do |args|
  Card::Content.truncatewords_with_closing_tags _render_core(args), words=100
end
view :preview do |args|
  Card::Content.truncatewords_with_closing_tags _render_core(args), words=40
end 
