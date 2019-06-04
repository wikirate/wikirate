
view :paragraph do
  Card::Content.smart_truncate _render_core, words = 100
end

view :preview do
  Card::Content.smart_truncate _render_core, words = 40
end
