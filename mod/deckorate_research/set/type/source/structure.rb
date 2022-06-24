include_set Abstract::DeckorateTabbed

format :html do
  before :content_formgroups do
    voo.edit_structure = form_fields
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
    %i[preview metric metric_answer details]
  end

  def tab_options
    { preview: { count: nil, label: "Preview" } }
  end

  view :preview_tab do
    render_preview
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :metric_answer_tab do
    field_nest :metric_answer, view: :filtered_content
  end

  view :details_tab, template: :haml

  def original_link
    return unless card.link_url.present?
    link_with_icon card.link_url, "external-link-square-alt", "original"
  end

  def download_link
    link_with_icon card.file_url, :download, "download"
  end

  def link_with_icon url, icon, title
    text = "#{fa_icon icon} #{title}"
    link_to text, href: url, target: "_blank"
  end
end
