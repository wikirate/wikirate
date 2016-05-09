view :needed, perms: :none do |_args|
  if card.real? && !card.content.empty?
    render_core
  else
    %(<span class="wanted-card">title needed</span>)
  end
end
