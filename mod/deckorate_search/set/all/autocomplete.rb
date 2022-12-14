format :html do
  def autocomplete_label
    haml :autocomplete_label
  end

  def autocomplete_name
    card.name
  end
end
