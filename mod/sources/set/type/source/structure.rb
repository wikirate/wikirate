include_set Abstract::TwoColumnLayout

format :html do
  # TODO: use more of two_column_layout defaults.  (but configure columns)
  view :open_content do
    hidden_information +
    bs_layout(container: false, fluid: true) do
      row 7, 5, class: "source-preview-container two-column-box" do
        column _render_preview, class: "source-preview nodblclick"
        column _render_right_column
      end
    end
  end

  before :content_formgroup do
    voo.edit_structure = form_fields
  end

  def form_fields
    flds = %i[wikirate_title report_type wikirate_company year wikirate_topic description]
    flds = flds.unshift :file if card.new?
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

  def original_link
    return unless card.link_url.present?
    link_with_icon card.link_url, "external-link-square", "Original"
  end

  def download_link
    link_with_icon card.file_url, :download, "Download"
  end

  def link_with_icon url, icon, title
    text = "#{fa_icon icon} #{title}"
    link_to text, href: url, target: "_blank", class: "source-color"
  end
end
