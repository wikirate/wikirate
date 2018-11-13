def preview_card
  fetch(trait: :preview) if file_card&.preview_card?
end

format :html do
  view :open_content do
    wrap do
      [hidden_information, render_source_preview_container]
    end
  end

  view :source_preview_container do
    bs_layout container: false, fluid: true do
      row 7, 5, class: "source-preview-container" do
        column _render_preview, class: "source-preview nodblclick"
        column _render_tabs, class: "source-tabs"
      end
    end
  end

  view :preview do
    if (preview_card = card.preview_card)
      nest preview_card, view: :content
    else
      nest  card.file_card, view: :preview
    end
  end

  def hidden_information
    wrap_with :div, class: "hidden" do
      [wrap_with(:div, card.name.url_key, id: "source-name"),
       wrap_with(:div, card.file_card&.file&.url, id: "source_url")]
    end
  end
end
