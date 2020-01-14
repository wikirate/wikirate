# def preview_card
#   fetch(:preview) if file_card&.preview_card?
# end

format :html do
  view :bar_and_preview, cache: :never do
    wrap do
      [render_close_icon,
       render_cite_bar(hide: %i[preview_link_bar freshen_button]),
       render_wikirate_copy_message,
       render_preview]
    end
  end

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
