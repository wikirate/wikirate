include_set Abstract::DeckorateTabbed

format :html do
  before :content_formgroups do
    voo.edit_structure = form_fields
  end

  def new_form_opts
    super.tap do |opts|
      if params[:layout] == "modal"
        opts.merge! "data-slotter-mode": "update-origin", class: "_close-modal"
      end
    end
  end

  def form_fields
    flds = %i[wikirate_title report_type company year description]
    if card.new?
      flds.unshift :file
    elsif card.wikirate_link_card.new?
      flds.unshift :wikirate_link
    end
    flds
  end

  def tab_list
    %i[details preview metric answer]
  end

  def tab_options
    { preview: { count: nil, label: "Preview" },
      answer: { label: "Data points" } }
  end

  view :preview_tab do
    render_preview
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :answer_tab do
    field_nest :answer, view: :filtered_content
  end

  view :details_tab_right, template: :haml

  view :details_tab_left do
    [
      field_nest(:description, view: :titled),
      field_nest(:discussion, view: :titled, show: :comment_box)
    ]
  end

  def original_link
    return unless card.link_url.present?
    link_with_icon card.link_url, :new_window, "Original"
  end

  def download_link
    link_with_icon card.file_url, :download, "Download"
  end

  def link_with_icon url, icon, title
    text = "#{icon_tag icon} #{title}"
    link_to text, href: url, target: "_blank"
  end
end
