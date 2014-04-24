view :needed, :perms=>:none do |args|
  if card.real?
    render_core
  else
    %(<span class="wanted-card">title needed</a>)
  end
end