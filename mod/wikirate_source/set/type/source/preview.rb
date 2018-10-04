include_set Abstract::Pdfjs
include_set Abstract::Tabs

format :html do
  view :preview, tags: :unknown_ok do
    wrap do
      [
        hidden_information,
        render_source_preview_container
      ]
    end
  end

  def preview_url
    @preview_url_loaded ? @preview_url : load_preview_url
  end

  def load_preview_url
    @preview_url_loaded = true
    @preview_url = card.fetch(trait: :wikirate_link)&.item_names&.first
  end

  view :source_preview_container, tags: :unknown_ok do
    bs_layout container: false, fluid: true do
      row 7, 5, class: "source-preview-content" do
        column _render_iframe_view, class: "source-iframe-container"
        column _render_tab_containers, class: "source-right-sidebar"
      end
    end
  end

  view :tab_containers, tags: :unknown_ok do
    # loading_gif_html = Card["loading gif"].format.render_core
    _render_tabs
  end

  view :iframe_view, tags: :unknown_ok, cache: :never do
    send "#{card.source_type_codename}_iframe_view"
  end

  def file_iframe_view
    mime = card.file_card&.file&.content_type
    if valid_mime_type? mime
      previewable_iframe_view mime
    else
      nonpreviewable_iframe_view
    end
  end

  def previewable_iframe_view mime
    method_prefix = mime == "application/pdf" ? :pdf : :standard_file
    send "#{method_prefix}_iframe_view"
  end

  def nonpreviewable_iframe_view
    wrap_with :div, id: "source-preview-iframe",
                    class: "webpage-preview non-previewable" do
      wrap_with :div, class: "redirect-notice" do
        _render_content structure: "source item preview"
      end
    end
  end

  def standard_file_iframe_view
    wrap_with :div, id: "pdf-preview", class: "webpage-preview" do
      wrap_with :img, "", id: "source-preview-iframe",
                          src: card.file_card.attachment.url
    end
  end

  def pdf_iframe_view
    wrap_with :div, id: "pdf-preview", class: "webpage-preview" do
      pdfjs_iframe pdf_url: card.file_card.attachment.url
    end
  end

  def wikirate_link_iframe_view
    wrap_with :div, id: "webpage-preview", class: "webpage-preview" do
      wrap_with :iframe, "",
                id: "source-preview-iframe", src: preview_url,
                sandbox: "allow-same-origin allow-scripts allow-forms",
                security: "restricted"
    end
  end

  def text_iframe_view
    wrap_with :div, class: "container-fluid" do
      wrap_with :div, class: "row-fluid" do
        wrap_with :div, id: "text_source", class: "webpage-preview" do
          text_card = card.fetch trait: :text
          nest text_card, view: "open", hide: "toggle", title: "Text Source"
        end
      end
    end
  end

  def valid_mime_type? mime_type
    return false unless mime_type
    mime_type == "application/pdf" || mime_type.start_with?("image/")
  end

  def hidden_information
    wrap_with :div, class: "hidden" do
      [
        wrap_with(:div, card.name.url_key, id: "source-name"),
        wrap_with(:div, preview_url, id: "source_url")
      ]
    end
  end

  view :non_previewable, tags: :unknown_ok do
    url, text = nonpreviewable_url_and_text
    link_to text, href: url, class: "btn btn-primary", role: "button"
  end

  def nonpreviewable_url_and_text
    if (file_card = card.file_card)
      [file_card.attachment.url, "Download"]
    else
      [preview_url, "Visit Original Source"]
    end
  end
end
