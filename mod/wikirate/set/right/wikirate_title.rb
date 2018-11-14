format :html do
  view :needed, perms: :none do
    if card.content.present?
      render_core
    else
      raw %(<span class="wanted-card">title needed</span>)
    end
  end
end
