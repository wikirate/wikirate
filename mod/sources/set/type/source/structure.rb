include_set Abstract::TwoColumnLayout

format :html do
  before :content_formgroups do
    voo.edit_structure = form_fields
  end

  view :open_content do
    two_column_layout 7, 5
  end

  view :left_column do
    render_preview
  end

  def form_fields
    flds = %i[wikirate_title report_type wikirate_company year description]
    if card.new?
      flds.unshift :file
    elsif card.wikirate_link_card.new?
      flds.unshift :wikirate_link
    end
    flds
  end

  def tab_list
    %i[details metric metric_answer]
  end

  view :source_details, template: :haml

  view :details_tab do
    tab_wrap do
      _render_source_details
    end
  end

  view :metric_tab do
    tab_wrap do
      field_nest :metric, items: { view: :bar }
    end
  end

  view :metric_answer_tab do
    tab_wrap do
      field_nest :metric_answer, items: { view: :bar }
    end
  end

  # download and original links.  (view makes them hideable)

  def original_link
    return unless card.link_url.present?
    link_with_icon card.link_url, "external-link-square-alt", "Original"
  end

  def download_link
    link_with_icon card.file_url, :download, "Download"
  end

  def source_page_link
    link_with_icon card.name.url_key, "external-link-alt", "Source Page"
  end

  def link_with_icon url, icon, title
    text = "#{fa_icon icon} #{title}"
    link_to text, href: url, target: "_blank", class: "source-color"
  end
end
