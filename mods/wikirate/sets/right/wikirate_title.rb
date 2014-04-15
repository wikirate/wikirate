view :needed, :perms=>:none do |args|
  if card.real?
    render_core
  else
    %(<span class="needed-title">title needed</a>)
  end
end