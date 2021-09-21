format :html do
  view :preview do
    wrap_with :div, class: "nodblclick" do
      nest card.file_card, view: :preview
    end
  end

  def hidden_information
    wrap_with :div, class: "hidden" do
      [wrap_with(:div, card.name.url_key, id: "source-name"),
       wrap_with(:div, card.file_card&.file&.url, id: "source_url")]
    end
  end
end
