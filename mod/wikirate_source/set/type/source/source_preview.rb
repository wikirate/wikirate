include_set Abstract::Pdfjs
include_set Abstract::Tabs

format :html do
  def related_claim_wql
    {
      left: {
        type_id: Card::ClaimID
      },
      right: "source",
      link_to: card.name,
      return: "count"
    }
  end

  def related_metric_wql
    {
      type_id: Card::MetricID,
      right_plus: [
        { type_id: Card::WikirateCompanyID },
        right_plus: [
          { type: "year" },
          right_plus: [
            "source", { link_to: card.name }
          ]
        ]
      ],
      return: "count"
    }
  end

  def note_count
    Card.search related_claim_wql
  end

  def metric_count
    Card.search related_metric_wql
  end

  view :preview, tags: :unknown_ok do
    wrap do
      [
        render_hidden_information,
        render_source_preview_container
      ]
    end
  end

  def preview_url
    if @preview_url_loaded
      @preview_url
    else
      url_card = card.fetch(trait: :wikirate_link)
      @preview_url = url_card ? url_card.item_names.first : nil
    end
  end

  def file_card
    card.fetch trait: :file
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
    file_card = card.fetch trait: :file
    mime = file_card.file.content_type
    return nonpreviewable_iframe_view unless mime && valid_mime_type?(mime)
    method_prefix = mime == "application/pdf" ? :pdf : :standard_file
    send "#{method_prefix}_iframe_view", file_card
  end

  def nonpreviewable_iframe_view
    wrap_with :div, id: "source-preview-iframe",
                    class: "webpage-preview non-previewable" do
      wrap_with :div, class: "redirect-notice" do
        _render_content structure: "source item preview"
      end
    end
  end

  def standard_file_iframe_view file_card
    wrap_with :div, id: "pdf-preview", class: "webpage-preview" do
      wrap_with :img, "", id: "source-preview-iframe",
                          src: file_card.attachment.url
    end
  end

  def pdf_iframe_view file_card
    wrap_with :div, id: "pdf-preview", class: "webpage-preview" do
      _render_pdfjs_iframe pdf_url: file_card.attachment.url
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
    mime_type == "application/pdf" || mime_type.start_with?("image/")
  end

  view :hidden_information, tags: :unknown_ok do |args|
    wrap_with :div, class: "hidden" do
      [
        wrap_with(:div, card.name.url_key, id: "source-name"),
        wrap_with(:div, preview_url, id: "source_url"),
        wrap_with(:div, args[:year], id: "source-year"),
        wrap_with(:div, args[:company], id: "source_company"),
        wrap_with(:div, args[:topic], id: "source_topic")
      ]
    end
  end

  view :non_previewable, tags: :unknown_ok do |_args|
    file_card = card.fetch trait: :file
    url, text = if file_card then [file_card.attachment.url, "Download"]
                else [preview_url, "Visit Original Source"]
                end
    link_to text, href: url, class: "btn btn-primary", role: "button"
  end
end
