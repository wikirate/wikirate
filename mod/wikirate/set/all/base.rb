
view :paragraph do |args|
  Card::Content.smart_truncate _render_core(args), words = 100
end

view :preview do |args|
  Card::Content.smart_truncate _render_core(args), words = 40
end
